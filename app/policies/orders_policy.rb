# Orders, customers, reports and partners: the sales side (Policies.ORDERS in the reference).
class OrdersPolicy < ApplicationPolicy
  def manage? = role?(ADMIN, MANAGER)
end
