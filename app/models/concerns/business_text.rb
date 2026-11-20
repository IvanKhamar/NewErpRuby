# Text helpers the business rules share (domain/common.py in the reference).
module BusinessText
  module_function

  # A number without extra zeros: 650, 650.5. With places, rounded half to even first, like the reference.
  def plain(value, places = nil)
    number = BigDecimal(value.to_s)
    number = number.round(places, half: :even) if places
    text = number.to_s("F").sub(/\.0+\z/, "").sub(/(\.\d*?)0+\z/, '\1')
    text == "-0" ? "0" : text
  end

  # A required text field: trimmed, not empty, not longer than max_length.
  def require_text(value, field, max_length)
    text = value.to_s.strip
    raise DomainError, "#{field}: значення обов'язкове." if text.empty?
    raise DomainError, "#{field}: не довше #{max_length} символів." if text.length > max_length

    text
  end

  def scale_ok?(number, places) = number.round(places) == number
end
