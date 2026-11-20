module Stock
  # A receipt (+) or a use (−) of a consumable, with a row in the movement log.
  #
  # Two people (or a person and a production write-off) may change one item at the same moment. The row is read
  # with SELECT … FOR UPDATE (`lock`) inside a transaction, so the second change waits for the first to commit and
  # then sees its quantity: no lost update, and the "not below zero" rule holds (DECISIONS.md D7).
  class Adjust < ApplicationService
    include BusinessText

    def initialize(item_id:, delta:, reason:, user:)
      @item_id = item_id
      @delta = delta
      @reason = reason
      @user = user
    end

    def call
      StockItem.transaction do
        item = StockItem.active.lock.find_by(item_id: @item_id)
        return not_found("Позицію складу #{@item_id} не знайдено.") if item.nil?

        require_main_warehouse_has(item) if @delta.negative?
        movement = item.adjust(@delta, @reason, @user)
        item.save!
        success(movement)
      end
    end

    private

    # Without a warehouse the change is for the main one: what lies at other warehouses is not used from here.
    def require_main_warehouse_has(item)
      located = StockLocation.where(item_id: item.id).sum(:quantity)
      main = item.stock - located
      return if located.zero? || main + @delta >= 0

      raise DomainError, "Недостатньо залишку на основному складі: є #{plain(main)} #{item.unit}, " \
                         "списується #{plain(-@delta)} #{item.unit}."
    end
  end
end
