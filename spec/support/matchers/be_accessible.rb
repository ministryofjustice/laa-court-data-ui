# frozen_string_literal: true

RSpec::Matchers.define :be_accessible do |exclusions: []|
  match do |page|
    @violations = AxeResults.new(page, exclusions:).violations
    @violations.none?
  end

  failure_message do
    details = @violations.map do |violation|
      nodes = violation.nodes.map do |node|
        [
          "    Target: #{node.target.inspect}",
          "    HTML: #{node.html}",
          "    Failure: #{node.failure_summary}",
        ].join("\n")
      end

      [
        "#{violation.id} (#{violation.impact}): #{violation.help}",
        "  #{violation.description}",
        "  Help: #{violation.help_url}",
        *nodes,
      ].join("\n")
    end

    "Expected page to be accessible, but found #{@violations.size} accessibility violation(s):\n\n#{details.join("\n\n")}"
  end
end
