# An IBAN (ISO 13616): the format, the length of its country and the mod 97 check digits.
#
#   Iban.new("UA21 3223 1300 0002 6007 2335 6600 1").valid?  # spaces and case do not matter
#
# The check: move the first four characters to the end, replace letters by numbers (A = 10 … Z = 35); the whole
# number mod 97 must be 1. One wrong digit or two swapped neighbours always change the remainder.
class Iban
  # Lengths from the SWIFT IBAN registry for the countries a Ukrainian shop's customers bank in most.
  LENGTHS = {
    "UA" => 29, "PL" => 28, "DE" => 22, "GB" => 22, "FR" => 27, "IT" => 27, "ES" => 24, "NL" => 18, "BE" => 16,
    "AT" => 20, "CZ" => 24, "SK" => 24, "LT" => 20, "LV" => 21, "EE" => 20, "MD" => 24, "RO" => 24, "HU" => 28,
    "BG" => 22, "IE" => 22, "PT" => 25, "SE" => 24, "FI" => 18, "DK" => 18, "NO" => 15, "CH" => 21, "GE" => 22
  }.freeze

  attr_reader :value

  def self.check_digits(country, bban)
    format("%02d", 98 - mod97("#{bban}#{country}00"))
  end

  # The remainder of a long IBAN number, in chunks, as ISO 7064 describes (no big integers needed).
  def self.mod97(text)
    digits = text.chars.map { |c| c.match?(/[A-Z]/) ? (c.ord - 55).to_s : c }.join
    digits.chars.each_slice(9).reduce(0) { |rest, chunk| "#{rest}#{chunk.join}".to_i % 97 }
  end

  def initialize(text)
    @value = text.to_s.gsub(/[[:space:]]/, "").upcase
  end

  def country = value[0, 2]

  # nil for a valid IBAN, else a message for people.
  def problem
    return "Вкажіть IBAN." if value.empty?
    unless value.match?(/\A[A-Z]{2}\d{2}[A-Z0-9]+\z/)
      return "IBAN має починатися з коду країни й двох контрольних цифр, далі лише латинські літери й цифри."
    end

    length = LENGTHS[country]
    return "IBAN країни #{country} не підтримується." if length.nil?
    return "IBAN країни #{country} має #{length} символів, а вказано #{value.length}." if value.length != length
    return "У рахунку UA після контрольних цифр мають бути 6 цифр МФО банку." if country == "UA" && !bank_code?
    return "Контрольні цифри IBAN не збігаються: мабуть, у номері помилка." unless self.class.mod97(rearranged) == 1

    nil
  end

  def valid? = problem.nil?

  # Groups of four, as people read it: UA21 3223 1300 …
  def formatted = value.scan(/.{1,4}/).join(" ")

  private

  def rearranged = value[4..] + value[0, 4]

  # A Ukrainian IBAN holds the bank's 6-digit MFO code right after the check digits.
  def bank_code? = value[4, 6].match?(/\A\d{6}\z/)
end
