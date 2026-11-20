# Consumables stock: the warehouse side (Policies.STOCK in the reference).
class StockPolicy < ApplicationPolicy
  def manage? = role?(ADMIN, STOREKEEPER)
end
