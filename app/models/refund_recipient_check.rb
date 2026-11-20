# One check of a refund recipient, whatever the result: the audit log (who checked which account, the answer).
class RefundRecipientCheck < ApplicationRecord
  ACCOUNT_NOT_FOUND = "account_not_found".freeze
  INVALID_IBAN = "invalid_iban".freeze
  RESULTS = [PayeeName::MATCH, PayeeName::CLOSE_MATCH, PayeeName::NO_MATCH, ACCOUNT_NOT_FOUND, INVALID_IBAN].freeze

  self.table_name = "erp_refund_recipient_check"

  belongs_to :user
  has_many :refunds, foreign_key: :recipient_check_id, inverse_of: :recipient_check, dependent: :restrict_with_error

  validates :result, inclusion: { in: RESULTS }

  scope :newest_first, -> { order(created_at: :desc, id: :desc) }

  def match? = result == PayeeName::MATCH
  def close_match? = result == PayeeName::CLOSE_MATCH
end
