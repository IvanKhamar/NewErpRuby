require "net/http"
require "resolv"

module Competitors
  # Loads a competitor's product page. The address was typed in by a person, so this is the one place where the
  # server makes requests to addresses from users, and it guards against SSRF (the reference's HttpPageFetcher):
  #
  # - the host is resolved first and every address must be public (no 127.0.0.1, 10.x, 192.168.x, 169.254.x...);
  # - the connection goes to that checked address (Net::HTTP#ipaddr), so a second DNS answer cannot swap it
  #   for a local one between the check and the connection (DNS rebinding);
  # - redirects are followed by hand and only within the competitor's site;
  # - the body is cut at 2 MB, every step has a timeout.
  #
  # Plain Net::HTTP instead of Faraday: Faraday's adapters do not expose the address pinning this needs.
  class PageFetcher
    class Error < StandardError; end

    MAX_REDIRECTS = 3
    MAX_BYTES = 2 * 1024 * 1024
    TIMEOUT = 20 # seconds
    HEADERS = { "User-Agent" => "Mozilla/5.0 (compatible; NewErp price check)",
                "Accept" => "text/html,application/xhtml+xml" }.freeze

    class TooLarge < StandardError; end
    private_constant :TooLarge

    # resolver: host → list of IP strings (tests pass a fixed one).
    def initialize(resolver: ->(host) { Resolv.getaddresses(host) })
      @resolver = resolver
    end

    def fetch(url, site_host)
      current = url
      (MAX_REDIRECTS + 1).times do
        raise Error, "Сторінка веде на інший сайт: #{PageAddress.host_of(current)}" unless PageAddress.on_site?(
          current, site_host
        )

        response, body = get(current)
        status = response.code.to_i
        return decode(body, response) if status == 200
        raise Error, "Сайт відповів HTTP #{status}." unless (300..399).cover?(status)
        raise Error, "Сайт переадресував без адреси (HTTP #{status})." if response["location"].blank?

        current = URI.join(current, response["location"]).to_s
      end
      raise Error, "Забагато переадресацій."
    end

    def self.public_address?(text)
      ip = IPAddr.new(text)
      ip = ip.native if ip.ipv4_mapped?
      return false if ip.loopback? || ip.private? || ip.link_local? || ip.to_i.zero?

      ip.ipv4? ? public_ipv4?(ip) : !IPAddr.new("ff00::/8").include?(ip) # rubocop:disable Rails/NegateInclude -- IPAddr has no exclude?
    rescue IPAddr::InvalidAddressError
      false
    end

    def self.public_ipv4?(ip)
      first = ip.to_s.split(".").first.to_i
      first.nonzero? && first < 224 && !IPAddr.new("100.64.0.0/10").include?(ip) # rubocop:disable Rails/NegateInclude -- 100.64/10: shared by providers; IPAddr has no exclude?
    end

    private

    def get(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.ipaddr = public_ip(uri.host)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = http.read_timeout = http.ssl_timeout = TIMEOUT
      body = +""
      response = http.request_get(uri.request_uri, HEADERS) { |res| read_limited(res, body) }
      [response, body]
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise Error, "Сайт не відповів за #{TIMEOUT} секунд."
    rescue SocketError, SystemCallError, OpenSSL::SSL::SSLError, IOError => e
      raise Error, "Сайт недоступний: #{e.class.name}."
    end

    def public_ip(host)
      addresses = @resolver.call(host)
      raise Error, "Сайт недоступний: адресу не знайдено." if addresses.empty?
      raise Error, "Адреса сайту веде в локальну мережу." unless addresses.all? { |a| self.class.public_address?(a) }

      addresses.first
    end

    def read_limited(response, body)
      response.read_body do |chunk|
        body << chunk
        raise TooLarge if body.bytesize >= MAX_BYTES
      end
    rescue TooLarge
      body.slice!(MAX_BYTES..) # the price is near the top of a page; the rest is not needed
    end

    # Ukrainian sites may still be in windows-1251; the charset from Content-Type says so.
    def decode(body, response)
      charset = response.type_params["charset"].presence || "UTF-8"
      body.force_encoding(charset).encode("UTF-8", invalid: :replace, undef: :replace)
    rescue ArgumentError, Encoding::ConverterNotFoundError
      body.force_encoding("UTF-8").scrub
    end
  end
end
