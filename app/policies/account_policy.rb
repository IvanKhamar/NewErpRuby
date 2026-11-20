# Any signed-in employee: their own account (who am I, change my password, log out).
class AccountPolicy < ApplicationPolicy
  def manage? = user.present?
end
