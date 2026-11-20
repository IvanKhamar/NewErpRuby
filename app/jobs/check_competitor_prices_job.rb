# Daily at 07:00 Kyiv time (config/schedule.yml), before managers start work.
class CheckCompetitorPricesJob < ApplicationJob
  queue_as :default

  def perform
    summary = Competitors::CheckPrices.call.value
    Rails.logger.info("competitor prices: #{summary.to_h}")
  end
end
