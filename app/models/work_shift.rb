# A cash register shift; receipts can only be issued while the cashier's shift is open (date_end is NULL).
class WorkShift < ApplicationRecord
  self.table_name = "dd_cashbox_work_shift"
  self.primary_key = "work_shift_id"

  belongs_to :cashier, foreign_key: :cashbox_user_id, inverse_of: :work_shifts

  scope :open, -> { where(date_end: nil) }
end
