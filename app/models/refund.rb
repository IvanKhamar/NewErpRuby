# Money sent back to a customer's account after a recipient check.
class Refund < ApplicationRecord
  self.table_name = "erp_refund"

  belongs_to :recipient_check, class_name: "RefundRecipientCheck", inverse_of: :refunds
  belongs_to :order
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
end
