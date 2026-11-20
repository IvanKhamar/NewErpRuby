# An employee: the old site's dd_user (MyISAM, shared with the old admin). NewErp access lives in erp_user_login.
class User < ApplicationRecord
  self.table_name = "dd_user"
  self.primary_key = "user_id"

  has_one :login, class_name: "UserLogin", inverse_of: :user, dependent: nil

  scope :active, -> { where(status: true) }

  delegate :role, :security_stamp, :must_change_password, to: :login, allow_nil: true

  def full_name = "#{firstname} #{lastname}".strip
end
