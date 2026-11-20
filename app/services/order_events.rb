# Order events for other systems: OrderCreated and OrderStatusChanged, the same JSON as the reference sends to the
# Kafka topic newerp.orders. The key is the order id, so Kafka keeps the events of one order in order.
#
# An event leaves only after the database transaction around it has committed (`after_all_transactions_commit`),
# so nobody hears about a change that was rolled back. Outside a transaction it leaves at once.
module OrderEvents
  TOPIC = "newerp.orders".freeze

  # Set in config/initializers/order_events.rb: Kafka when brokers are set, else the log.
  mattr_accessor :publisher

  module_function

  def created(order_id:, status_id:, manager_id:, source_id:, total:, occurred_at:)
    publish(order_id, message("OrderCreated", occurred_at).merge(
                        "orderId" => order_id, "statusId" => status_id, "managerId" => manager_id,
                        "orderSourceId" => source_id, "total" => total.to_f
                      ))
  end

  def status_changed(change)
    publish(change.order_id, message("OrderStatusChanged", change.changed_at).merge(
                               "orderId" => change.order_id, "oldStatusId" => change.old_status_id,
                               "newStatusId" => change.new_status_id, "userId" => change.user_id
                             ))
  end

  # eventId lets a reader skip a repeat; occurredAt is Kyiv wall-clock time like everything in the API.
  def message(type, occurred_at)
    { "eventId" => SecureRandom.uuid, "type" => type, "occurredAt" => occurred_at.strftime("%Y-%m-%dT%H:%M:%S") }
  end

  def publish(order_id, payload)
    ActiveRecord.after_all_transactions_commit { publisher.publish(TOPIC, order_id.to_s, payload) }
  end

  # Without Kafka the events only go to the log, so local work needs no broker.
  class LogPublisher
    def publish(topic, key, payload)
      Rails.logger.info("order event #{topic} key=#{key} #{payload.to_json}")
    end
  end
end
