# Where order events go: Kafka when NEWERP_KAFKA_BROKERS is set (for example kafka:9092 with the compose profile
# "kafka"), else only the log, so local work and tests need no broker. to_prepare runs again after a code reload
# in development, when the reloaded module has lost its publisher.
Rails.application.config.to_prepare do
  next if OrderEvents.publisher

  brokers = ENV.fetch("NEWERP_KAFKA_BROKERS", "")
  OrderEvents.publisher = brokers.empty? ? OrderEvents::LogPublisher.new : OrderEvents::KafkaPublisher.build(brokers)
end
