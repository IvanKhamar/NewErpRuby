require "rails_helper"

RSpec.describe StockItem do
  subject(:item) { build(:stock_item, stock: 5, unit: "м") }

  let(:user) { create(:user) }

  it { is_expected.to belong_to(:category).class_name("StockCategory").optional }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:unit).is_at_most(32) }

  it "builds a log row with every change" do
    movement = item.adjust(BigDecimal("-1.5"), "Пошив", user)

    expect(item.stock).to eq(3.5)
    expect(movement).to have_attributes(action: "use", quantity: 1.5, stock_before: 5, stock_after: 3.5)
  end

  it "keeps at most two decimals" do
    expect { item.adjust(BigDecimal("0.001"), "x", user) }.to raise_error(DomainError, /2 знаків після коми/)
  end

  it "takes for production only what there is" do
    movement = item.take_up_to(BigDecimal("7.125"), "Крій", user)

    expect(movement.quantity).to eq(5)
    expect(item.stock).to eq(0)
    expect(item.take_up_to(BigDecimal(1), "Крій", user)).to be_nil
  end

  it "finds items below their minimum with a scope" do
    low = create(:stock_item, stock: 1, min_stock: 2)
    create(:stock_item, stock: 3, min_stock: 2)

    expect(described_class.below_minimum).to contain_exactly(low)
  end
end
