# Hourly (config/schedule.yml): Nova Poshta waybill statuses. A failure of the service is retried by Sidekiq later.
class RefreshDeliveryTrackingJob < ApplicationJob
  queue_as :default
  retry_on NovaPoshta::Client::Error, wait: :polynomially_longer, attempts: 5

  def perform
    summary = Delivery::RefreshTracking.call.value
    Rails.logger.info("delivery tracking: #{summary.to_h}")
  end
end
