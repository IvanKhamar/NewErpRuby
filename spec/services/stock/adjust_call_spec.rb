require "rails_helper"

# Two changes of one item at the same moment, in two threads with their own database connections.
# Without the row lock both would read 10 and the last write would win (lost update); with it the second waits.
RSpec.describe Stock::Adjust, ".call" do
  # Threads need committed data and their own transactions, so this example does not run inside a test transaction.
  self.use_transactional_tests = false

  let(:item) { create(:stock_item, stock: 10) }
  let(:user) { create(:user) }

  after do
    StockLog.where(item_id: item.id).delete_all
    item.destroy!
    UserLogin.where(user_id: user.id).delete_all
  end

  def adjust_in_threads(deltas)
    ready = Queue.new
    go = Queue.new
    threads = deltas.map do |delta|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          go.pop # start both changes together
          described_class.call(item_id: item.id, delta: BigDecimal(delta), reason: "Паралельно", user:)
        end
      end
    end
    deltas.size.times { ready.pop }
    deltas.size.times { go << true }
    threads.map(&:value)
  end

  it "applies two concurrent changes, none is lost" do
    results = adjust_in_threads([-3, -4])

    expect(results).to all(be_success)
    expect(item.reload.stock).to eq(3)
    expect(StockLog.where(item_id: item.id).pluck(:stock_after)).to contain_exactly(7, 3).or contain_exactly(6, 3)
  end

  it "keeps the never-below-zero rule under concurrency: one of two large uses succeeds" do
    results = adjust_in_threads([-7, -6])

    expect(results.count(&:success?)).to eq(1)
    expect(results.find(&:failure?).error).to start_with("Недостатньо залишку")
    expect(item.reload.stock).to be_in([3, 4])
  end
end
