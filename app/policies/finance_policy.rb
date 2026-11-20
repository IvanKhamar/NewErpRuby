# Money: card payment links, bank payments, fiscal receipts (Policies.FINANCE in the reference).
class FinancePolicy < ApplicationPolicy
  def manage? = role?(ADMIN, MANAGER)
end
