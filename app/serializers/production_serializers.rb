# JSON of the production API (ProductionModelSummaryDto, ProductionModelDto, ProductionOperationResult).
module ProductionSerializers
  class Summary < ApplicationSerializer
    attribute(:id, &:production_id)
    attributes :name, :type, :min_total
    attribute(:total_cut) { |m| json_number(m.total_cut) }
    attribute(:total_sewn) { |m| json_number(m.total_sewn) }
    attribute(:deficit) { |m| json_number([m.min_total - m.total_sewn, 0].max) }
  end

  class Size < ApplicationSerializer
    attribute(:id, &:size_id)
    attribute(:name, &:size_name)
    attribute(:percent) { |s| json_number(s.percent) }
    attribute(:cut_stock) { |s| json_number(s.cut_stock) }
    attribute(:sewn_stock) { |s| json_number(s.sewn_stock) }
    attribute(:option_value_id, &:oc_option_value_id)
  end

  class CategoryLink < ApplicationSerializer
    attribute(:category_id, &:oc_category_id)
    attributes :name_filter
    attribute(:match_exact) { |c| c.match_exact ? true : false }
  end

  class ComponentBomLine < ApplicationSerializer
    attributes :size_id, :item_id
    attribute(:item_name) { |l| l.item&.name }
    attribute(:unit) { |l| l.item&.unit }
    attribute(:qty_per_unit) { |l| json_number(l.qty_per_unit) }
  end

  class Component < ApplicationSerializer
    attribute(:id, &:component_id)
    attributes :name, :sort_order
    # Cut parts in stock by size id ({"12": 4.0}).
    attribute(:stock) { |c| c.stocks.to_h { |s| [s.size_id.to_s, json_number(s.stock)] } }
    many :bom_lines, key: :bom, resource: ComponentBomLine
  end

  class SewnBomLine < ApplicationSerializer
    attributes :size_id, :component_id
    attribute(:component_name) { |l| l.component&.name }
    attributes :item_id
    attribute(:item_name) { |l| l.item&.name }
    attribute(:unit) { |l| l.item&.unit }
    attribute(:qty_per_unit) { |l| json_number(l.qty_per_unit) }
  end

  class Model < ApplicationSerializer
    attribute(:id, &:production_id)
    attributes :name, :type, :min_total, :sort_order
    many :sizes, resource: Size
    attribute(:product_ids) { |m| m.product_links.map(&:product_id) }
    many :category_links, key: :categories, resource: CategoryLink
    many :components, resource: Component
    many :sewn_bom_lines, key: :sewn_bom, resource: SewnBomLine
  end

  class SizeChange < ApplicationSerializer
    attributes :size_id, :size_name
    attribute(:before) { |c| json_number(c.before) }
    attribute(:after) { |c| json_number(c.after) }
  end

  class OperationResult < ApplicationSerializer
    many :sizes, resource: SizeChange
    attributes :warnings
  end
end
