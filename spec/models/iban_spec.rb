require "rails_helper"

RSpec.describe Iban do
  # Published example IBANs (ECBS / bank documentation), not real customers' accounts.
  let(:examples) do
    { "GB" => "GB82WEST12345698765432", "DE" => "DE89370400440532013000",
      "UA" => "UA213223130000026007233566001", "PL" => "PL61109010140000071219812874" }
  end

  it "accepts the published examples, with spaces and in any case" do
    examples.each_value { |iban| expect(described_class.new(iban)).to be_valid, iban }
    expect(described_class.new("ua21 3223 1300 0002 6007 2335 6600 1")).to be_valid
  end

  it "computes mod 97 piece by piece like the full number" do
    number = "3223130000026007233566001UA21"
    digits = number.chars.map { |c| c.match?(/[A-Z]/) ? (c.ord - 55).to_s : c }.join

    expect(described_class.mod97(number)).to eq(digits.to_i % 97)
    expect(described_class.mod97(number)).to eq(1)
  end

  it "builds the check digits for a BBAN" do
    expect(described_class.check_digits("UA", "3223130000026007233566001")).to eq("21")
    expect(described_class.check_digits("GB", "WEST12345698765432")).to eq("82")
  end

  it "catches every single-digit error in the account part" do
    iban = examples["UA"]
    (4...iban.length).each do |position|
      next unless iban[position].match?(/\d/)

      wrong = iban.dup
      wrong[position] = ((iban[position].to_i + 1) % 10).to_s
      expect(described_class.new(wrong).problem).to include("Контрольні цифри"), "position #{position}"
    end
  end

  it "catches two swapped neighbouring digits" do
    swapped = examples["UA"].dup
    swapped[6], swapped[7] = swapped[7], swapped[6] # "…3223…" becomes "…3232…"
    expect(swapped).not_to eq(examples["UA"]) # the example has different digits there

    expect(described_class.new(swapped)).not_to be_valid
  end

  it "checks the length of the country: 29 characters for Ukraine" do
    expect(described_class.new("#{examples['UA']}0").problem).to eq("IBAN країни UA має 29 символів, а вказано 30.")
    expect(described_class.new(examples["UA"][0..-2]).problem).to eq("IBAN країни UA має 29 символів, а вказано 28.")
  end

  it "explains the other problems for people" do
    expect(described_class.new("").problem).to eq("Вкажіть IBAN.")
    expect(described_class.new("1234").problem).to start_with("IBAN має починатися з коду країни")
    expect(described_class.new("XX00123").problem).to eq("IBAN країни XX не підтримується.")
    expect(described_class.new("UA21ABCDEF0000026007233566001").problem).to include("6 цифр МФО")
  end

  it "groups digits by four for people" do
    expect(described_class.new(examples["UA"]).formatted).to eq("UA21 3223 1300 0002 6007 2335 6600 1")
  end
end
