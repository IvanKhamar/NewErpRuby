# Role checks with Pundit. NewErp's roles guard whole modules (the reference's `Policies` in api/security.py),
# so the policies are "headless": controllers call `authorize :orders, :manage?` with a symbol, not a record.
class ApplicationPolicy
  ADMIN = "Admin".freeze
  MANAGER = "Manager".freeze
  STOREKEEPER = "Storekeeper".freeze

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def role?(*roles) = roles.include?(user&.role)
end
