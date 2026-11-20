# Stock of cut parts of one size. Sewing takes parts from here.
class ComponentStock < ApplicationRecord
  self.table_name = "dd_stock_production_component_stock"
  self.primary_key = %i[component_id size_id]

  belongs_to :component, class_name: "ProductionComponent", inverse_of: :stocks

  # Parts went to sewing. If there are too few, what there is gets taken; returns the amount taken.
  def take_up_to(wanted)
    taken = [wanted, stock].min.clamp(0..) # never below zero, even if the stock already is
    self.stock -= taken
    taken
  end
end
