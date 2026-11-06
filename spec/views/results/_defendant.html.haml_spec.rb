# frozen_string_literal: true

RSpec.describe "results/_defendant.html.haml", type: :view do
  subject(:render_partial) do
    render partial: "results/defendant", locals: { results:, xhibit_case_number: }
  end

  let(:results) do
    [view.decorate(build(:defendant_summary, prosecution_case_reference: "TEST12345"),
                   Cda::DefendantSummaryDecorator)]
  end

  context "when the search is by Xhibit case reference" do
    let(:xhibit_case_number) { "T20254007" }

    it { is_expected.to have_css(".govuk-table__header", text: "Xhibit ref") }
    it { is_expected.to have_css(".govuk-table__cell", text: "T20254007") }
  end

  context "when the search is not by Xhibit case reference" do
    let(:xhibit_case_number) { nil }

    it { is_expected.to have_no_css(".govuk-table__header", text: "Xhibit ref") }
    it { is_expected.to have_css(".govuk-table__header", count: 4) }
  end
end
