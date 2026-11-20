# Shared Faraday setup of the outside-service clients: JSON in and out, timeouts on every call, and retries with a
# growing pause for network errors and 429/5xx answers. Only idempotent requests are retried by default; a client
# that may repeat a POST says so (retry_post: true) and explains why.
module HttpClient
  module_function

  def connection(url, retry_post: false, timeout: 20)
    Faraday.new(url:) do |f|
      f.request :json
      f.request :retry, max: 2, interval: 0.5, backoff_factor: 2, retry_statuses: [429, 500, 502, 503, 504],
                        methods: retry_post ? %i[get post] : %i[get]
      f.response :json, content_type: /\bjson$/
      f.options.open_timeout = 5
      f.options.timeout = timeout
    end
  end
end
