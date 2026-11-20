module Orders
  # Changes an order's status and writes the change to the status log.
  #
  # What other modules do on a status change lives in status handlers (Orders::StatusHandlers), not in a big
  # `case` over statuses here: a new rule is a new handler class. Handlers run before the status is saved, so if one
  # fails, the status stays old and the action can simply be repeated; they skip a repeated write-off themselves.
  class ChangeStatus < ApplicationService
    # publish: false for a new order's first status, which its OrderCreated event already carries.
    def initialize(order_id:, status_id:, user:, publish: true, handlers: StatusHandlers.all)
      @order_id = order_id
      @status_id = status_id
      @user = user
      @publish = publish
      @handlers = handlers
    end

    def call
      order = Order.find_by(order_id: @order_id)
      return not_found("Замовлення #{@order_id} не знайдено.") if order.nil?
      return failure("Статусу #{@status_id} не існує.") unless OrderStatus.exists_with_id?(@status_id)
      return failure("Користувача #{@user.id} не знайдено або його вимкнено.") unless User.active.exists?(@user.id)

      change = OrderStatusChange.build(order, @status_id, @user)
      warnings = save(order, change)
      OrderEvents.status_changed(change) if @publish
      success(warnings)
    end

    private

    # The handlers write to InnoDB tables (sewn stock), which roll back if saving the status fails. The order
    # tables themselves are MyISAM (no transactions), as on the old site.
    def save(order, change)
      ApplicationRecord.transaction do
        warnings = @handlers.flat_map { |handler| handler.call(change) }
        order.update!(order_status_id: change.new_status_id, date_modified: change.changed_at)
        OrderStatusLog.create!(order_id: order.id, user_id: change.user_id, old_status_id: change.old_status_id,
                               new_status_id: change.new_status_id, date_added: change.changed_at)
        warnings
      end
    end
  end
end
