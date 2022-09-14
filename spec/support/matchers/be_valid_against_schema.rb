# frozen_string_literal: true

require 'rspec/expectations'

# be_valid_against_schema
# e.g. expect(json_data).to be_valid_against_schema([schema: json_schema, fragement: schema_fragment])
#
RSpec::Matchers.define :be_valid_against_schema do |options = {}|
  schema_errors = []
  match do |data|
    options[:schema] ||= default_schema
    options[:fragment] ||= '#/definitions/prosecution_case/definitions/resource_collection'

    errors = JSON::Validator.fully_validate(
      options[:schema],
      data,
      fragment: options[:fragment],
      strict: true,
      validate_schema: true
    )
    schema_errors = errors
    errors.empty?
  end

  def default_schema
    Rails.root.join('config', 'schemas', 'prosecution_case_search_result.json').read
  end

  description do
    'data valid against schema'
  end

  failure_message do |_data|
    "expected errors to be empty but got\n #{schema_errors}"
  end
end
