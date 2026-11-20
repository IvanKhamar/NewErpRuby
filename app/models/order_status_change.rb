# A status change on its way to the log. Status handlers (Orders::StatusHandlers) get it before it is saved.
# old_status_id 0 / new_status_id 0 mean "no status": a new order enters its first status from 0.
OrderStatusChange = Data.define(:order_id, :old_status_id, :new_status_id, :user_id, :changed_at) do
  def self.build(order, new_status_id, user, now: Time.current)
    raise DomainError, "Статус має бути додатним числом." unless new_status_id.to_i.positive?
    raise DomainError, "Замовлення вже має цей статус." if new_status_id == order.order_status_id

    new(order_id: order.id, old_status_id: order.order_status_id, new_status_id:, user_id: user.id, changed_at: now)
  end

  def entering?(status_ids) = status_ids.exclude?(old_status_id) && status_ids.include?(new_status_id)
  def leaving?(status_ids) = status_ids.include?(old_status_id) && status_ids.exclude?(new_status_id)
end
