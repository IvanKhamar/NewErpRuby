require "rails_helper"

RSpec.describe OrderEvents do
  # Collects what would go to Kafka.
  let(:published) { [] }
  let(:fake_publisher) do
    sink = published
    Class.new { define_method(:publish) { |topic, key, payload| sink << [topic, key, payload] } }.new
  end
  let(:user) { create(:user) }
  let(:order) { create(:order, order_status_id: 18) }

  before do
    allow(described_class).to receive(:publisher).and_return(fake_publisher)
    # (the default one is checked below; here the events are only collected)
    create(:order_status, order_status_id: 18)
    create(:order_status, order_status_id: 22)
  end

  it "sends OrderStatusChanged with the order id as the key, in the reference's JSON" do
    Orders::ChangeStatus.call(order_id: order.id, status_id: 22, user:)

    topic, key, payload = published.sole
    expect([topic, key]).to eq(["newerp.orders", order.id.to_s])
    expect(payload).to include("type" => "OrderStatusChanged", "orderId" => order.id, "oldStatusId" => 18,
                               "newStatusId" => 22, "userId" => user.id)
    expect(payload["eventId"]).to match(/\A\h{8}-\h{4}-/)
    expect(payload["occurredAt"]).to match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\z/)
  end

  it "waits for the commit and sends nothing when the transaction rolls back" do
    ApplicationRecord.transaction(requires_new: true) do
      Orders::ChangeStatus.call(order_id: order.id, status_id: 22, user:)
      expect(published).to be_empty # not yet: the transaction is still open
      raise ActiveRecord::Rollback
    end

    expect(published).to be_empty
  end

  it "sends nothing when the status change is refused" do
    Orders::ChangeStatus.call(order_id: order.id, status_id: 18, user:)

    expect(published).to be_empty
  end

  it "logs the events when no Kafka brokers are set (the default publisher in tests)" do
    allow(described_class).to receive(:publisher).and_call_original

    expect(described_class.publisher).to be_a(OrderEvents::LogPublisher)
  end
end
