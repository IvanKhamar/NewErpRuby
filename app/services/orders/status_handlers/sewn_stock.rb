module Orders
  module StatusHandlers
    # Sewn pieces and orders (the old site's StockTrack event). When an order enters one of the write-off statuses,
    # pieces of the needed size leave the sewn stock; when it leaves them, they come back.
    #
    # Idempotent: what the order already holds is read from the production log, so a repeated call (a failure
    # after the write-off but before the status was saved, or a write-off the old site already did) neither takes
    # nor returns twice.
    class SewnStock
      include BusinessText

      SYSTEM = Data.define(:id, :username) # automatic log rows are signed "system", as on the old site

      def initialize(status_ids: ErpSettings.sewn_subtract_status_ids)
        @status_ids = status_ids
      end

      def call(change)
        return [] unless change.entering?(@status_ids) || change.leaving?(@status_ids)

        lines = Production::OrderSizeLines.new(change.order_id)
        by_size = lines.by_size
        warnings = lines.warnings.dup
        return warnings if by_size.empty?

        actor = SYSTEM.new(id: change.user_id, username: "system")
        held = ProductionLog.sewn_held_by_order(change.order_id)
        # Rows are locked in a fixed order (by id), so two orders taking the same sizes cannot deadlock.
        sizes = ProductionSize.lock.includes(:model).where(size_id: by_size.keys).order(:size_id).index_by(&:id)
        by_size.each do |size_id, quantity|
          size = sizes.fetch(size_id)
          warning = if change.entering?(@status_ids)
                      take(size, quantity, held, change, actor)
                    else
                      give_back(size, quantity, held, change, actor)
                    end
          warnings << warning if warning
        end
        warnings
      end

      private

      def take(size, quantity, held, change, actor)
        missing = quantity - held[size.id]
        return unless missing.positive?

        entry = size.take_for_order(missing, change.order_id, actor)
        size.save!
        taken = entry&.quantity || 0
        return if taken >= missing

        "Пошитих «#{size.model.name}» розміру #{size.size_name} бракує #{plain(missing - taken, 3)} шт.: " \
          "списано #{plain(taken, 3)} з #{plain(missing, 3)}."
      end

      # Returns not more than the order really holds. The old module returned the full quantity even when pieces
      # were short at the write-off, and so "made" pieces that did not exist.
      def give_back(size, quantity, held, change, actor)
        to_return = [quantity, held[size.id]].min
        return unless to_return.positive?

        size.return_from_order(to_return, change.order_id, actor)
        size.save!
        nil
      end
    end
  end
end
