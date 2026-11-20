# A partner's commission is a transaction on their customer balance (OpenCart 3).
class CustomerTransaction < ApplicationRecord
  self.table_name = "dd_customer_transaction"
  self.primary_key = "customer_transaction_id"
end
