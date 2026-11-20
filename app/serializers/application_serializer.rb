# Base of the API serializers (Alba). JSON keys are camelCase like the reference contract (userId, statusName).
class ApplicationSerializer
  include Alba::Resource

  transform_keys :lower_camel

  # Helpers for attribute blocks, which run on the serializer instance.

  # The contract has plain JSON numbers; Rails would write a BigDecimal as a string.
  def number(value) = value&.to_f

  # Kyiv wall-clock time without an offset, as the database keeps it and the reference writes it (DECISIONS.md D8).
  def local_time(value) = value&.strftime("%Y-%m-%dT%H:%M:%S")
end
