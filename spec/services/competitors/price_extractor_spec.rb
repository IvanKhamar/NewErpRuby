require "rails_helper"

RSpec.describe Competitors::PriceExtractor do
  describe ".parse_price" do
    it "reads the usual ways shops write prices" do
      expect(described_class.parse_price("1 299,00")).to eq(BigDecimal("1299.00"))
      expect(described_class.parse_price("1,299.50")).to eq(BigDecimal("1299.50"))
      expect(described_class.parse_price("1299.5")).to eq(BigDecimal("1299.5"))
      expect(described_class.parse_price("1 299 грн")).to eq(1299)
      expect(described_class.parse_price("1 299")).to eq(1299) # a no-break space between thousands
      expect(described_class.parse_price("1.299")).to eq(1299) # one separator with three digits: thousands
      expect(described_class.parse_price("ціна за запитом")).to be_nil
      expect(described_class.parse_price("0")).to be_nil
    end
  end

  describe ".extract" do
    it "finds the price in the product meta tag" do
      html = '<meta property="product:price:amount" content="1450.00">'

      expect(described_class.extract(html)).to eq(1450)
    end

    it "tries the competitor's own pattern first" do
      html = '<span class="cost">999 грн</span><meta itemprop="price" content="1200">'

      expect(described_class.extract(html, 'class="cost">([0-9 ]+)')).to eq(999)
    end

    it "gives up on a catastrophic pattern instead of hanging, and falls back to the markup" do
      html = "#{'a' * 40}!<meta itemprop=\"price\" content=\"700\">"
      # A backreference turns off the regex memoization of Ruby 3.2+, so this backtracks exponentially on "a"s.
      evil = '(a|a)+\1$'

      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      price = described_class.extract(html, evil)

      expect(price).to eq(700)
      expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - started).to be < described_class::TIMEOUT + 2
    end
  end

  it "stops a backtracking pattern with Regexp::TimeoutError" do
    pattern = Regexp.new('(a|a)+\1$', timeout: 0.2)

    expect { pattern.match("#{'a' * 40}!") }.to raise_error(Regexp::TimeoutError)
  end

  describe ".pattern_problem" do
    it "needs a group for the price and a pattern that compiles" do
      expect(described_class.pattern_problem("")).to be_nil
      expect(described_class.pattern_problem('price">([0-9]+)')).to be_nil
      expect(described_class.pattern_problem("price")).to include("групу в дужках")
      expect(described_class.pattern_problem("([0-9]")).to start_with("Вираз для ціни з помилкою")
    end
  end
end
