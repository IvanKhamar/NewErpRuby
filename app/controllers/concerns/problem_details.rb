# Errors as RFC 9457 Problem Details, with the same "type" links and Ukrainian titles as the reference
# (NewErpPython api/errors.py, which copies ASP.NET Core), so a client of any version reads them the same way.
module ProblemDetails
  extend ActiveSupport::Concern

  TYPES = {
    400 => "https://tools.ietf.org/html/rfc9110#section-15.5.1",
    401 => "https://tools.ietf.org/html/rfc9110#section-15.5.2",
    403 => "https://tools.ietf.org/html/rfc9110#section-15.5.4",
    404 => "https://tools.ietf.org/html/rfc9110#section-15.5.5",
    409 => "https://tools.ietf.org/html/rfc9110#section-15.5.10",
    429 => "https://tools.ietf.org/html/rfc6585#section-4",
    500 => "https://tools.ietf.org/html/rfc9110#section-15.6.1"
  }.freeze

  BUSINESS_RULE = "Порушено бізнес-правило".freeze
  NOT_FOUND = "Не знайдено".freeze
  BAD_REQUEST = "Некоректний запит".freeze
  BAD_BODY = "Не вдалося прочитати тіло запиту: перевірте, що це правильний JSON у кодуванні UTF-8.".freeze

  # A request parameter of the wrong type (?page=abc): the client's error, like a Pydantic validation error.
  class InvalidParameter < StandardError; end

  included do
    # Handlers declared later win, so the catch-all comes first.
    rescue_from StandardError, with: :render_internal_error
    rescue_from DomainError, with: ->(e) { render_problem(400, BUSINESS_RULE, e.message) }
    rescue_from ActiveRecord::RecordNotFound, with: ->(_) { render_problem(404, NOT_FOUND) }
    rescue_from InvalidParameter, with: ->(e) { render_problem(400, BAD_REQUEST, e.message) }
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: ->(_) { render_problem(400, BAD_REQUEST, BAD_BODY) }
    rescue_from ActionController::ParameterMissing, with: ->(_) { render_problem(400, BAD_REQUEST, BAD_BODY) }
    rescue_from Pundit::NotAuthorizedError, with: ->(_) { head :forbidden } # 403 with an empty body, like .NET
  end

  private

  def render_problem(status, title, detail = nil, headers: {})
    body = { type: TYPES.fetch(status, "about:blank"), title:, status: }
    body[:detail] = detail unless detail.nil?
    headers.each { |name, value| response.set_header(name, value) }
    render json: body, status:, content_type: "application/problem+json"
  end

  # A failed ApplicationService::Result.
  def render_failure(result)
    if result.kind == :not_found
      render_problem(404, NOT_FOUND, result.error)
    else
      render_problem(400, BUSINESS_RULE, result.error)
    end
  end

  # A 500 never shows exception details; the log has them. Tests see the real exception.
  def render_internal_error(error)
    raise error if Rails.env.test?

    Rails.logger.error("Unhandled error: #{error.class}: #{error.message}\n#{error.backtrace&.first(20)&.join("\n")}")
    render_problem(500, "An error occurred while processing your request.")
  end
end
