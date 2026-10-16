# frozen_string_literal: true

RSpec.describe AxeResults do
  subject(:results) { described_class.new(page, exclusions:) }

  let(:page) { Capybara::Session.new(:playwright) }
  let(:exclusions) { [] }
  let(:violations) { [violation] }
  let(:console_message) do
    instance_double(Playwright::ConsoleMessage, text: { "violations" => violations }.to_json)
  end
  let(:node) do
    {
      "target" => ["#email"],
      "html" => '<input id="email">',
      "failureSummary" => "Fix any of the following:\n  Form element does not have a label",
    }
  end
  let(:violation) do
    {
      "id" => "label",
      "impact" => "critical",
      "tags" => %w[wcag2a wcag412],
      "description" => "Ensure every form element has a label",
      "help" => "Form elements must have labels",
      "helpUrl" => "https://dequeuniversity.com/rules/axe/4.13/label",
      "nodes" => [node],
    }
  end

  before do
    allow(page.driver).to receive(:with_playwright_page) { console_message }
  end

  it "preserves the rule details" do
    expect(results.violations.first).to have_attributes(
      id: "label",
      impact: "critical",
      tags: %w[wcag2a wcag412],
      description: violation["description"],
      help: violation["help"],
      help_url: violation["helpUrl"],
    )
  end

  it "preserves the affected element details" do
    expect(results.violations.first.nodes).to contain_exactly(
      described_class::Node.new(
        target: node["target"],
        html: node["html"],
        failure_summary: node["failureSummary"],
      ),
    )
  end

  context "when the violation is excluded" do
    let(:exclusions) { [described_class::ExclusionRule.new(id: "label", selector: "#email")] }

    it "does not return the excluded violation" do
      expect(results.violations).to be_empty
    end
  end

  describe "be_accessible matcher" do
    before do
      allow(described_class).to receive(:new).with(page, exclusions:).and_return(results)
    end

    it "reports the rule and every affected element without repeating the scan" do
      violation["nodes"] << node.merge("target" => ["#name"], "html" => '<input id="name">')
      matcher = be_accessible

      expect(matcher.matches?(page)).to be false
      expect(matcher.failure_message).to include(
        "1 accessibility violation(s)",
        "label (critical): #{violation['help']}",
        violation["description"],
        violation["helpUrl"],
        'Target: ["#email"]',
        'HTML: <input id="email">',
        'Target: ["#name"]',
        'HTML: <input id="name">',
        node["failureSummary"],
      )
      expect(page.driver).to have_received(:with_playwright_page).once
    end

    it "reports every violated rule" do
      violations << violation.merge("id" => "another-rule")
      matcher = be_accessible

      expect(matcher.matches?(page)).to be false
      expect(matcher.failure_message).to include("2 accessibility violation(s)", "label (critical)", "another-rule (critical)")
    end

    context "when there are no violations" do
      let(:violations) { [] }

      it "matches an accessible page" do
        expect(page).to be_accessible
      end
    end

    context "when the violation is excluded" do
      let(:exclusions) { [described_class::ExclusionRule.new(id: "label", selector: "#email")] }

      it "passes the exclusions through to the scan" do
        expect(page).to be_accessible(exclusions:)
      end
    end
  end
end
