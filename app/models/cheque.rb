# A sale receipt of an order (dd_cashbox_cheque). checkbox_id is empty until Checkbox has accepted it.
class Cheque < ApplicationRecord
  self.table_name = "dd_cashbox_cheque"
  self.primary_key = "cheque_id"

  belongs_to :order
  belongs_to :cashier, foreign_key: :cashbox_user_id, inverse_of: false

  def fiscalized? = checkbox_id.present?
end
