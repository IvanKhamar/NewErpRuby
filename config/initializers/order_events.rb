# Where order events go. Kafka is switched on by NEWERP_KAFKA_BROKERS (phase 5); without it they go to the log.
Rails.application.config.to_prepare do
  Rails.configuration.x.order_events_publisher ||= OrderEvents::LogPublisher.new
end
