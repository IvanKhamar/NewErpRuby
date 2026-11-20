module OrderEvents
  # Writes order events to Kafka with WaterDrop (the producer half of Karafka). The key is the order id: Kafka sends
  # equal keys to the same partition, so the events of one order are read in the order they were written.
  #
  # The event leaves after the database commit (OrderEvents.publish). If Kafka is down at that moment, the event is
  # lost and logged; the order itself stays. A transactional outbox would close that gap, but the order tables are
  # MyISAM (no transactions), so an outbox row could not be written atomically with the order either; the reference
  # makes the same choice (DECISIONS.md D17).
  class KafkaPublisher
    def self.build(brokers)
      producer = WaterDrop::Producer.new do |config|
        config.id = "newerp-ruby"
        config.deliver = true
        config.kafka = {
          "bootstrap.servers": brokers,
          "request.required.acks": -1,   # every in-sync replica has the event before it counts as sent
          "enable.idempotence": true,    # a retry inside the client never writes the event twice
          "message.timeout.ms": 10_000
        }
      end
      at_exit { producer.close }
      new(producer)
    end

    def initialize(producer)
      @producer = producer
    end

    def publish(topic, key, payload)
      @producer.produce_sync(topic:, key:, payload: payload.to_json)
    rescue WaterDrop::Errors::BaseError, Rdkafka::RdkafkaError => e
      Rails.logger.error("order event lost: #{topic} key=#{key} #{payload['type']}: #{e.class}: #{e.message}")
    end
  end
end
