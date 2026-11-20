# Base of the business operations in app/services: one public class method `call`, which returns a Result.
#
# A Result is explicit: `success?` with a value, or a failure with a message for people and a kind (:invalid for a
# broken business rule, :not_found). Controllers turn it into JSON or a flash message; jobs log it.
# A DomainError raised deep inside (by a model method) becomes a failure here, after its transaction rolled back.
class ApplicationService
  Result = Data.define(:value, :error, :kind) do
    def success? = error.nil?
    def failure? = !success?
  end

  def self.call(...)
    new(...).call
  rescue DomainError => e
    Result.new(value: nil, error: e.message, kind: :invalid)
  end

  private

  def success(value = nil) = Result.new(value:, error: nil, kind: nil)
  def failure(message, kind: :invalid) = Result.new(value: nil, error: message, kind:)
  def not_found(message) = failure(message, kind: :not_found)
end
