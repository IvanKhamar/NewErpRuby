require "rails_helper"

RSpec.describe "Business rules of plain models" do
  describe CustomerRisk do
    it "grades a customer by the share of cancelled orders" do
      cancelled = ErpSettings.cancelled_status_id

      expect(described_class.of([]).level).to eq(CustomerRisk::NEW)
      expect(described_class.of([[1, 18], [2, 22]]).level).to eq(CustomerRisk::GREEN)
      expect(described_class.of([[1, cancelled], [2, 22], [3, 22]])).to have_attributes(
        level: CustomerRisk::YELLOW, cancelled_order_ids: [1], suspicion_rate: BigDecimal("33.33")
      )
      expect(described_class.of([[1, cancelled], [2, 22]]).level).to eq(CustomerRisk::RED)
    end

    it "compares phones by their last nine digits" do
      expect(described_class.phone_key("+38 (067) 123-45-67")).to eq(described_class.phone_key("0671234567"))
      expect(described_class.phone_key("12345")).to be_nil
    end
  end

  describe OrderDraft do
    def draft(lines: [OrderDraft::Line.new(1, nil, 2, BigDecimal(500))], shipping: 0, discount: 0, prepayment: 0)
      described_class.new(lines:, shipping_cost: BigDecimal(shipping), discount: BigDecimal(discount),
                          prepayment: BigDecimal(prepayment))
    end

    it "counts products + shipping − discount" do
      expect(draft(shipping: 80, discount: 30).total).to eq(1050)
    end

    it "needs a name or a phone and both methods" do
      expect do
        draft.validate_customer!(firstname: " ", telephone: "", shipping_method: "x", payment_method: "y")
      end.to raise_error(DomainError, "Вкажіть ім'я або телефон клієнта.")
    end

    it "refuses a discount above the sum and a prepayment above the total" do
      expect { draft(discount: 2000).validate_lines! }.to raise_error(DomainError, /Знижка не може перевищувати/)
      expect { draft(prepayment: 5000).validate_lines! }.to raise_error(DomainError, /завдатку/)
    end
  end

  describe Production::Bom do
    let(:line) { Struct.new(:size_id, :item_id) }

    it "takes a row for the size over a general row, one per consumable" do
      general = line.new(nil, 7)
      for_m = line.new(12, 7)
      other = line.new(nil, 8)

      expect(described_class.resolve([general, for_m, other], 12, :item_id)).to contain_exactly(for_m, other)
      expect(described_class.resolve([general, for_m, other], 13, :item_id)).to contain_exactly(general, other)
    end
  end

  describe BusinessText do
    it "writes numbers without extra zeros" do
      expect(described_class.plain(BigDecimal("650.00"))).to eq("650")
      expect(described_class.plain(BigDecimal("2.50"))).to eq("2.5")
      expect(described_class.plain(BigDecimal("1.23456"), 3)).to eq("1.235")
    end
  end

  describe UkrainianSort do
    it "puts є, і, ї and ґ in their Ukrainian places" do
      names = %w[Їжак Ігор Ганна Ґудзик Євген Яна]

      expect(names.sort_by { |n| described_class.key(n) }).to eq(%w[Ганна Ґудзик Євген Ігор Їжак Яна])
    end
  end
end
