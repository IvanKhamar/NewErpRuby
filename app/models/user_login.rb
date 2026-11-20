# NewErp login of an employee: password hash (ASP.NET Core Identity v3 format, shared with the other versions),
# role and the security stamp. A new stamp ends every session of the user at once.
class UserLogin < ApplicationRecord
  ROLES = %w[Admin Manager Storekeeper].freeze

  self.table_name = "erp_user_login"
  self.primary_key = "user_id"

  belongs_to :user, inverse_of: :login

  validates :role, inclusion: { in: ROLES }

  def self.new_stamp = SecureRandom.hex(16)
end
