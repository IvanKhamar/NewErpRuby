# A cashier of the software cash register (dd_cashbox_user). The old site also kept Checkbox logins and keys in
# this table; NewErp never reads those columns: the keys come from ENV (Checkbox::Client.build).
class Cashier < ApplicationRecord
  self.table_name = "dd_cashbox_user"
  self.primary_key = "user_id"
  self.ignored_columns += %w[login password checkbox_key access_token]

  has_many :work_shifts, foreign_key: :cashbox_user_id, inverse_of: :cashier, dependent: nil
end
