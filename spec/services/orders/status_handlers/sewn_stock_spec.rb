require "rails_helper"

RSpec.describe Orders::StatusHandlers::SewnStock do
  subject(:handler) { described_class.new(status_ids: [18, 22]) }

  let(:model) { create(:production_model, name: "Сукня Лана") }
  let!(:size_m) { create(:production_size, model:, size_name: "M", sewn_stock: 5, oc_option_value_id: 41) }
  let(:order) { create(:order, order_status_id: 1) }
  let(:user) { create(:user) }

  before do
    line = create(:order_product, order:, product_id: 300, name: "Сукня Лана", quantity: 2)
    ProductionProduct.create!(production_id: model.id, product_id: 300)
    value = ProductOptionValue.create!(product_id: 300, product_option_id: 1, option_id: 11, option_value_id: 41,
                                       quantity: 0, subtract: true, price: 0, price_prefix: "+", points: 0,
                                       points_prefix: "+", weight: 0, weight_prefix: "+")
    OrderOption.create!(order_id: order.id, order_product_id: line.id, product_option_id: 1,
                        product_option_value_id: value.id, name: "Розмір", value: "M", type: "radio")
  end

  def change(from, to)
    OrderStatusChange.new(order_id: order.id, old_status_id: from, new_status_id: to,
                          user_id: user.id, changed_at: Time.current)
  end

  it "takes the pieces when the order enters a write-off status" do
    expect(handler.call(change(1, 18))).to eq([])
    expect(size_m.reload.sewn_stock).to eq(3)
  end

  it "is idempotent: a repeated call takes nothing more" do
    handler.call(change(1, 18))
    handler.call(change(1, 18))

    expect(size_m.reload.sewn_stock).to eq(3)
    expect(ProductionLog.where(comment: "Замовлення ##{order.id}").count).to eq(1)
  end

  it "does nothing between two write-off statuses and gives the pieces back on leaving them" do
    handler.call(change(1, 18))
    handler.call(change(18, 22))
    expect(size_m.reload.sewn_stock).to eq(3)

    handler.call(change(22, 19))
    expect(size_m.reload.sewn_stock).to eq(5)
  end

  it "takes what there is and warns about the rest" do
    size_m.update!(sewn_stock: 1)

    warnings = handler.call(change(1, 18))

    expect(warnings.sole).to eq("Пошитих «Сукня Лана» розміру M бракує 1 шт.: списано 1 з 2.")
    expect(size_m.reload.sewn_stock).to eq(0)
  end

  it "returns only what the order really took" do
    size_m.update!(sewn_stock: 1)
    handler.call(change(1, 18))

    handler.call(change(18, 19))

    expect(size_m.reload.sewn_stock).to eq(1)
  end
end
