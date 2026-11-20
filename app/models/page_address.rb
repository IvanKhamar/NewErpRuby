# Rules for page addresses that people type in (competitor sites and product pages).
module PageAddress
  module_function

  # nil when the address is fine, else a message for people.
  def problem(value, field, max_length)
    text = value.to_s.strip
    return "#{field}: вкажіть адресу до #{max_length} символів." unless text.length.between?(1, max_length)

    uri = parse(text)
    return "#{field}: це не схоже на адресу сторінки." if uri.nil? || uri.scheme.nil? || uri.host.nil?
    return "#{field}: адреса має починатися з http:// або https://." unless %w[http https].include?(uri.scheme.downcase)

    nil
  end

  def valid?(value) = problem(value, "", 500).nil?

  # Scheme and host in lower case and "/" for an empty path, as .NET's Uri writes it (the other versions do too).
  def normalize(value)
    uri = parse(value.to_s.strip)
    uri.scheme = uri.scheme.downcase
    uri.host = uri.host.downcase
    uri.path = "/" if uri.path.empty?
    uri.to_s
  end

  # The host in lower case without "www.": shop.ua for https://www.Shop.ua/catalog.
  def host_of(url) = parse(url.to_s)&.host.to_s.downcase.delete_prefix("www.")

  # The same host or its subdomain (m.shop.ua is on shop.ua).
  def on_site?(url, site_host)
    host = host_of(url)
    host == site_host || host.end_with?(".#{site_host}")
  end

  def parse(text)
    URI.parse(text)
  rescue URI::InvalidURIError
    nil
  end
end
