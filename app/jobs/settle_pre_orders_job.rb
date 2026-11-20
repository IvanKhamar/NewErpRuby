# Hourly (config/schedule.yml). Jobs stay thin: they call a service and log its result.
class SettlePreOrdersJob < ApplicationJob
  queue_as :default

  def perform
    result = PreOrders::Settle.call
    Rails.logger.info("pre-orders settled: #{result.value} sizes")
  end
end
