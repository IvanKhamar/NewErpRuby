# Typed access to config/newerp.yml.
module ErpSettings
  module_function

  def language_id = config[:language_id]
  def sewn_subtract_status_ids = config.dig(:production, :order_subtract_status_ids)
  def cancelled_status_id = config.dig(:orders, :cancelled_status_id)
  def risk_lookback_years = config.dig(:orders, :risk_lookback_years)
  def config = Rails.configuration.newerp
end
