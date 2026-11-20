# Production: models, BOMs, cutting and sewing (Policies.STOCK in the reference, like the consumables).
class ProductionPolicy < ApplicationPolicy
  def manage? = role?(ADMIN, STOREKEEPER)
end
