module Competitors
  # The product price on a shop page: first the competitor's own pattern (when set), then the usual markup
  # (the product:price:amount meta tag, an itemprop="price" element, "price" in schema.org JSON-LD).
  #
  # A competitor's pattern is written by people and the page comes from a foreign site, so every match runs with a
  # time limit: Regexp timeout (Ruby 3.2+) stops a catastrophic backtracking pattern instead of hanging the job.
  module PriceExtractor
    TIMEOUT = 2.0 # seconds per pattern
    MAX_PATTERN_LENGTH = 255

    STANDARD = [
      /property=["']product:price:amount["'][^>]*content=["']([^"']+)["']/i,
      /content=["']([^"']+)["'][^>]*property=["']product:price:amount["']/i,
      /itemprop=["']price["'][^>]*content=["']([^"']+)["']/i,
      /content=["']([^"']+)["'][^>]*itemprop=["']price["']/i,
      /"price"\s*:\s*"?([0-9][0-9[:space:].,]*)/
    ].map { |pattern| Regexp.new(pattern.source, pattern.options, timeout: TIMEOUT) }.freeze

    # [[:space:]] also matches the no-break spaces shops put between thousands (\s in Ruby does not).
    NUMBER = /[0-9][0-9[:space:].,]*/

    module_function

    def extract(html, custom_pattern = nil)
      return nil if html.blank?

      patterns = STANDARD
      if custom_pattern.present?
        patterns = [Regexp.new(custom_pattern, Regexp::IGNORECASE | Regexp::MULTILINE, timeout: TIMEOUT)] + STANDARD
      end
      patterns.each do |pattern|
        price = first_price(pattern, html)
        return price if price
      end
      nil
    end

    # Checks a pattern from people: it must compile and have a group for the price. Empty means no own pattern.
    def pattern_problem(pattern)
      return nil if pattern.blank?
      return "Вираз для ціни — не довше #{MAX_PATTERN_LENGTH} символів." if pattern.length > MAX_PATTERN_LENGTH

      Regexp.new(pattern) # raises RegexpError for a broken pattern
      # Ruby has no "count the groups" call: "pattern|" always matches an empty string, and its MatchData then
      # has one slot per group of the pattern.
      return nil unless Regexp.new("#{pattern}|").match("").captures.empty?

      "Вираз для ціни має містити групу в дужках, наприклад class=\"price\">([0-9 ]+)."
    rescue RegexpError => e
      "Вираз для ціни з помилкою: #{e.message}"
    end

    # "1 299,00", "1,299.00", "1299.5" or "1 299 грн" as a number: spaces split thousands; of a comma and a dot the
    # last one is the decimal point; a single comma or dot with three digits after it splits thousands.
    def parse_price(text)
      number = text.to_s[NUMBER]
      return nil if number.nil?

      digits = number.gsub(/[[:space:]]/, "").sub(/[.,]+\z/, "")
      point = [digits.rindex(","), digits.rindex(".")].compact.max
      if point
        whole = digits[0...point].delete(",.")
        fraction = digits[(point + 1)..]
        only_one_kind = !(digits.include?(",") && digits.include?("."))
        thousands = only_one_kind && fraction.length == 3 && digits.index(digits[point]) == point && whole.present?
        digits = thousands ? "#{whole}#{fraction}" : "#{whole}.#{fraction}"
      end
      price = BigDecimal(digits)
      price.positive? ? price : nil
    rescue ArgumentError
      nil
    end

    def first_price(pattern, html)
      html.scan(pattern) do
        price = parse_price(Regexp.last_match(1))
        return price if price
      end
      nil
    rescue Regexp::TimeoutError
      nil # the pattern ran out of time: no price from it, the next one is tried
    end
  end
end
