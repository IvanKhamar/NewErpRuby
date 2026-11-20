# Rich text the storefront shows as HTML (FAQ answers, descriptions): cleaned before saving.
#
# Rails' SafeListSanitizer (the HTML5 one, on the Nokogiri HTML5 parser) keeps only the listed tags and attributes,
# like nh3 in the reference and HtmlSanitizer in .NET: a <script>, an onclick=, a javascript: link or a style never
# reach the database, so an editor's account cannot be used to attack the shop's customers (stored XSS).
module HtmlContent
  TAGS = %w[a b blockquote br caption div em h2 h3 h4 h5 hr i img li ol p s small span strong sub sup table tbody td
            tfoot th thead tr u ul].freeze
  ATTRIBUTES = %w[href title target src alt width height colspan rowspan class].freeze
  PROTOCOLS = %w[http https mailto tel].freeze
  DROPPED_WITH_CONTENT = "script, style, iframe, object, embed, noscript, template, textarea, select".freeze

  module_function

  def clean(value)
    return "" if value.blank?

    # Elements whose content is code or hidden, not text, go with their content (nh3 does the same); the safe list
    # alone would keep "alert(1)" from a <script> as visible text.
    without_code = Nokogiri::HTML5.fragment(value).tap { |f| f.css(DROPPED_WITH_CONTENT).remove }.to_html
    html = sanitizer.sanitize(without_code, tags: TAGS, attributes: ATTRIBUTES)
    # Links that open a new tab must not give the new page access to this one (window.opener).
    Nokogiri::HTML5.fragment(html).tap do |fragment|
      fragment.css("a").each do |link|
        link.remove_attribute("href") unless safe_url?(link["href"])
        link["rel"] = "noopener noreferrer"
      end
      fragment.css("img").each { |img| img.remove_attribute("src") unless safe_url?(img["src"]) }
    end.to_html
  end

  def sanitizer = @sanitizer ||= Rails::HTML5::SafeListSanitizer.new

  # Only absolute http(s), mailto and tel addresses, or relative ones; never javascript: or data:.
  def safe_url?(url)
    return false if url.blank?

    scheme = url.to_s.strip[/\A([a-z][a-z0-9+.-]*):/i, 1]
    scheme.nil? || PROTOCOLS.include?(scheme.downcase)
  end
end
