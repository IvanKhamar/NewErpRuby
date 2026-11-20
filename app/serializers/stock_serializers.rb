# JSON of the consumables stock API (StockItemDto, StockMovementDto in docs/openapi.json).
module StockSerializers
  class Item < ApplicationSerializer
    attribute(:id, &:item_id)
    attributes :name, :unit, :category_id
    attribute(:category_name) { |i| i.category&.name }
    attributes :supplier_id
    attribute(:supplier_name) { |i| i.supplier&.name }
    attribute(:quantity) { |i| number(i.stock) }
    attribute(:min_quantity) { |i| number(i.min_stock) }
    attribute(:is_below_minimum, &:below_minimum?)
    attribute(:used_for) { |i| i.used_for.to_s }
    attribute(:price) { |i| number(i.price) }
  end

  class Movement < ApplicationSerializer
    attribute(:id, &:log_id)
    attributes :item_id
    attribute(:delta) { |m| number(m.delta) }
    attribute(:quantity_before) { |m| number(m.stock_before) }
    attribute(:quantity_after) { |m| number(m.stock_after) }
    attribute(:reason) { |m| m.comment.to_s }
    attribute(:user_id) { |m| m.user_id.to_i }
    attributes :username
    attribute(:created_at) { |m| local_time(m.date_added) }
  end

  class Category < ApplicationSerializer
    attribute(:id, &:category_id)
    attributes :name
  end
end
