# Request specs check requests and responses against the reference contract, docs/openapi.json (committee-rails).
#
# One change is made in memory, not in the file: the contract marks times "date-time", which openapi_parser reads
# as RFC 3339 with an offset, while every version writes Kyiv wall-clock time without one (DECISIONS.md D8).
# Such fields get a pattern for "2026-11-20T10:15:00" instead.
module Contract
  LOCAL_DATE_TIME = '\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?\z'.freeze

  module_function

  def schema
    @schema ||= begin
      data = local_times(JSON.parse(Rails.root.join("docs/openapi.json").read))
      Committee::Drivers.load_from_data(data, nil, parser_options: { strict_reference_validation: true })
    end
  end

  def local_times(node)
    case node
    when Hash
      if node["format"] == "date-time"
        node.except("format").merge("pattern" => LOCAL_DATE_TIME)
      else
        node.transform_values { |value| local_times(value) }
      end
    when Array then node.map { |value| local_times(value) }
    else node
    end
  end
end

module ContractHelpers
  include Committee::Rails::Test::Methods

  def committee_options
    @committee_options ||= { schema: Contract.schema, parse_response_by_content_type: false }
  end

  # The response matches the contract for this path, method and status.
  def expect_contract(status)
    expect(response).to have_http_status(status)
    assert_response_schema_confirm(status)
  end
end

RSpec.configure do |config|
  config.include ContractHelpers, type: :request
end
