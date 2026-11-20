module Api
  module V1
    # Base of the JSON API. Paths are the reference contract's (docs/openapi.json), at the root, not /api/v1:
    # the web interfaces of the other versions call them as they are (DECISIONS.md D2).
    class BaseController < ActionController::API
      include ActionController::Cookies
      include Authentication
      include Pundit::Authorization
      include ProblemDetails

      # Every endpoint must check a role: an action that forgets `authorize` fails loudly in tests.
      after_action :verify_authorized

      private

      def pundit_user = Current.user

      def request_authentication
        head :unauthorized # 401 with an empty body, like the cookie scheme in .NET
      end

      def render_json(serializer, object, status: :ok)
        render json: serializer.new(object).serialize, status:
      end

      # Query and path parameters with the types of the reference: a wrong value is a 400, not a silent nil or 0.
      def int_param(name, default: nil)
        value = params[name]
        return default if value.blank?
        raise InvalidParameter, "Некоректні параметри запиту: #{name}." unless value.to_s.match?(/\A[+-]?\d+\z/)

        value.to_i
      end

      def bool_param(name, default: false)
        value = params[name]
        return default if value.nil?
        return true if %w[true 1].include?(value.to_s.downcase)
        return false if %w[false 0].include?(value.to_s.downcase)

        raise InvalidParameter, "Некоректні параметри запиту: #{name}."
      end

      def date_param(name)
        value = params[name]
        return nil if value.blank?

        Date.iso8601(value.to_s)
      rescue Date::Error
        raise InvalidParameter, "Некоректні параметри запиту: #{name}."
      end

      # A JSON number or numeric string in the body, like a Pydantic Decimal ("number|string" in the contract).
      def decimal_value(value, name, default: 0)
        return BigDecimal(default.to_s) if value.nil?

        BigDecimal(value.to_s)
      rescue ArgumentError, TypeError
        raise InvalidParameter, "Некоректні параметри запиту: #{name}."
      end

      def integer_value(value, name, default: 0)
        return default if value.nil?
        return value if value.is_a?(Integer)

        raise InvalidParameter, "Некоректні параметри запиту: #{name}."
      end
    end
  end
end
