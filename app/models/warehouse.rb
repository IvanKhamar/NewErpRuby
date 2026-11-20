# A warehouse other than the main one (showroom, partner shop).
class Warehouse < ApplicationRecord
  self.table_name = "dd_warehouse"
  self.primary_key = "warehouse_id"
end
