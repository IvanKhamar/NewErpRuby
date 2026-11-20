# An account whose holder we know: a local register standing in for a bank's Confirmation of Payee service.
class RefundKnownAccount < ApplicationRecord
  self.table_name = "erp_refund_known_account"

  before_validation { self.iban = Iban.new(iban).value }

  validates :holder_name, presence: true
  validate { errors.add(:iban, Iban.new(iban).problem) unless Iban.new(iban).valid? }
end
