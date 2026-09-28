# frozen_string_literal: true

RSpec::Matchers.define :be_accessible do |exclusions: []|
  match do |page|
    results = AxeResults.new(page, exclusions:)
    results.violations.none?
  end
end
