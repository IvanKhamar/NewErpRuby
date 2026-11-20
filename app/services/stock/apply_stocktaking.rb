module Stock
  # Sets every counted item in the place to the counted quantity, all in one transaction with the rows locked:
  # if any count is wrong, nothing is written. The total changes by the same difference, the log says
  # "Інвентаризація". value is the money the differences are worth (+ found, − missing).
  class ApplyStocktaking < ApplicationService
    Summary = Data.define(:counted, :changed, :value)

    def initialize(counts:, comment:, warehouse_id:, user:)
      @counts = counts
      @comment = comment.to_s.strip.empty? ? Stocktaking::COMMENT : "#{Stocktaking::COMMENT}: #{comment.strip}"
      @warehouse_id = warehouse_id
      @user = user
    end

    def call
      return failure("Немає жодної порахованої позиції.") if @counts.empty?

      duplicate = @counts.map(&:item_id).tally.find { |_, n| n > 1 }&.first
      return failure("Позицію #{duplicate} указано двічі.") if duplicate
      return not_found("Склад #{@warehouse_id} не знайдено.") if @warehouse_id && !Warehouse.exists?(@warehouse_id)

      StockItem.transaction { success(apply_all) }
    end

    private

    def apply_all
      items = StockItem.active.lock.where(item_id: @counts.map(&:item_id)).order(:item_id).index_by(&:id)
      booked = Stocktaking.booked(items.values, @warehouse_id)
      changed = 0
      value = BigDecimal(0)
      @counts.sort_by(&:item_id).each do |count|
        item = items[count.item_id] || raise(DomainError, "Позиції #{count.item_id} немає на складі.")
        delta = count.actual - booked[item.id]
        next if delta.zero?

        recount(item, count.actual, delta)
        changed += 1
        value += delta * item.price
      end
      Summary.new(counted: @counts.size, changed:, value: value.round(2, half: :up))
    end

    def recount(item, actual, delta)
      raise DomainError, "#{item.name}: загальний залишок став би від'ємним." if (item.stock + delta).negative?

      item.adjust(delta, @comment[0, 255], @user)
      item.save!
      return unless @warehouse_id

      location = StockLocation.lock.find_or_initialize_by(item_id: item.id, warehouse_id: @warehouse_id)
      location.update!(quantity: actual)
    end
  end
end
