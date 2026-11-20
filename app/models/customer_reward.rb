# Reward points of a customer (OpenCart). Positive rows were given for an order, negative ones spent on it.
class CustomerReward < ApplicationRecord
  self.table_name = "dd_customer_reward"
  self.primary_key = "customer_reward_id"

  scope :given, -> { where("points > 0") }
end
