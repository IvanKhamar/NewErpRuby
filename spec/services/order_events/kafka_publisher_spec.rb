require "rails_helper"

RSpec.describe OrderEvents::KafkaPublisher do
  it "writes JSON with the key and logs instead of failing when Kafka is down" do
    producer = instance_double(WaterDrop::Producer)
    allow(producer).to receive(:produce_sync).and_raise(WaterDrop::Errors::ProduceError, "broker down")
    allow(Rails.logger).to receive(:error)

    described_class.new(producer).publish("newerp.orders", "7", { "type" => "OrderCreated" })

    expect(producer).to have_received(:produce_sync).with(topic: "newerp.orders", key: "7",
                                                          payload: '{"type":"OrderCreated"}')
    expect(Rails.logger).to have_received(:error).with(/order event lost: newerp.orders key=7 OrderCreated/)
  end
end
