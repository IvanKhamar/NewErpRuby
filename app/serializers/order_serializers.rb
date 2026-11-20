# JSON of the orders API (OrderListItem, OrderDetails and friends in docs/openapi.json).
module OrderSerializers
  class ListItem < ApplicationSerializer
    attribute(:id, &:order_id)
    attribute(:date_added) { |o| json_time(o.date_added) }
    attribute(:customer, &:customer_name)
    attributes :telephone
    attribute(:total) { |o| json_number(o.total) }
    attributes :currency_code
    attribute(:status_id, &:order_status_id)
    attribute(:status_name) { |o| o.status&.name }
    attribute(:source_name) { |o| o.source&.name }
    attribute(:manager_id) { |o| o.manager&.id }
    attribute(:manager_name) { |o| o.manager&.full_name }
  end

  class ProductLine < ApplicationSerializer
    attributes :product_id, :name, :model, :quantity
    attribute(:price) { |p| json_number(p.price) }
    attribute(:total) { |p| json_number(p.total) }
  end

  class StatusHistoryEntry < ApplicationSerializer
    attribute(:changed_at) { |log| json_time(log.date_added) }
    attributes :old_status_id, :new_status_id
    attribute(:new_status_name) { |log| log.new_status&.name }
    attributes :user_id
    attribute(:user_name) { |log| log.user&.full_name }
  end

  class Details < ApplicationSerializer
    attribute(:id, &:order_id)
    attribute(:date_added) { |o| json_time(o.date_added) }
    attribute(:customer, &:customer_name)
    attributes :telephone, :email, :shipping_method, :shipping_city
    attribute(:shipping_address, &:shipping_address)
    attributes :payment_method, :comment
    attribute(:total) { |o| json_number(o.total) }
    attributes :currency_code
    attribute(:status_id, &:order_status_id)
    attribute(:status_name) { |o| o.status&.name }
    attribute(:source_id, &:order_source_id)
    attribute(:source_name) { |o| o.source&.name }
    attribute(:manager_id) { |o| o.manager&.id }
    attribute(:manager_name) { |o| o.manager&.full_name }
    many :products, resource: ProductLine
    many :status_logs, key: :status_history, resource: StatusHistoryEntry
    attribute(:date_shipping) { |o| o.date_shipping&.iso8601 }
    attribute(:invoice, &:invoice)
  end

  class Status < ApplicationSerializer
    attribute(:id, &:order_status_id)
    attributes :name, :color
  end

  class CustomerRisk < ApplicationSerializer
    attributes :level, :total_orders
    attribute(:cancelled_orders) { |r| r.cancelled_order_ids.size }
    attributes :cancelled_order_ids
    attribute(:suspicion_rate) { |r| json_number(r.suspicion_rate) }
    attributes :message
    attribute(:shared_ip) { nil }
  end

  class CreateResult < ApplicationSerializer
    attributes :order_id, :warnings
    one :risk, resource: CustomerRisk
  end

  class Credits < ApplicationSerializer
    attributes :order_id, :customer_id, :reward_points, :reward_added, :affiliate_id
    attribute(:commission) { |c| json_number(c.commission) }
    attributes :commission_added
  end
end
