# frozen_string_literal: true

require "ostruct"

RSpec.describe "link_migrated_cases/show_link.html.haml", type: :view do
  let(:defendant_id) { "def-1" }

  let(:defendant) do
    build(:defendant_summary,
          id: defendant_id,
          first_name: "Peter",
          middle_name: "Apple",
          last_name: "Rabbit",
          date_of_birth: Date.new(1990, 1, 1),
          arrest_summons_number: "AS123",
          national_insurance_number: "AB123456C",
          offence_summaries: [offence_summary])
  end

  let(:migrated_case) do
    build(:link_migrated_case,
          case_urn: "TEST12345",
          defendant_id: defendant_id,
          committal_date: nil,
          sent_date: Date.new(2024, 3, 1),
          xhibit_case_number: "X123",
          court_name: "Southwark",
          process_errors: { "message" => "MAAT application not found" })
  end

  let(:verdict) { double(type: double(description: "Guilty")) }

  let(:offence_summary) do
    build(:offence_summary, :with_laa_application, verdict:)
  end

  let(:hearing_day) { Date.new(2024, 3, 1) }
  let(:prosecution_case) { double(sorted_hearing_summaries_with_day: [double(day: hearing_day)]) }
  let(:offence_history_collection) { Cda::OffenceHistoryCollection.new(offence_histories: [offence_history]) }
  let(:offence_history) { Cda::OffenceHistory.new(id: "123", pleas: [], mode_of_trial_reasons: []) }
  let(:form_model) { LinkAttempt.new(defendant_id: defendant_id, username: "tester") }

  before do
    assign(:defendant, defendant)
    assign(:migrated_case, migrated_case)
    assign(:prosecution_case, prosecution_case)
    assign(:offence_history_collection, offence_history_collection)
    assign(:form_model, form_model)

    allow(view).to receive(:default_form_builder).and_return(GOVUKDesignSystemFormBuilder::FormBuilder)

    # Helpers used in the view
    allow(view).to receive_messages(service_name: "LAA",
                                    formatted_process_errors: "MAAT application not found",
                                    offences_defendant_path: "/offences")

    allow(view).to receive(:render).and_call_original
  end

  it "renders the page heading and case details" do
    render

    expect(rendered).to include("Link court data")

    expect(rendered).to include('<strong class="govuk-tag govuk-tag--blue">Trial</strong>')

    expect(rendered).to include("Name")
    expect(rendered).to include("Peter Apple Rabbit")

    expect(rendered).to include("Date of birth")
    expect(rendered).to include("1 Jan 1990")

    expect(rendered).to include("URN")
    expect(rendered).to include("TEST12345")

    expect(rendered).to include("ASN")
    expect(rendered).to include("AS123")

    expect(rendered).to include("NI number")
    expect(rendered).to include("AB123456C")

    expect(rendered).to include("Committal date")
    expect(rendered).to include("1 Mar 2024")

    expect(rendered).to include("Xhibit reference")
    expect(rendered).to include("X123")

    expect(rendered).to include("Court")
    expect(rendered).to include("Southwark")

    expect(rendered).to include("Latest hearing date")
    expect(rendered).to include("1 Mar 2024")

    expect(rendered).to include("Reason for manual linking")
    expect(rendered).to include("MAAT application not found")
  end

  it "renders the linking form" do
    render

    expect(rendered).to have_css("form")
    expect(rendered).to have_field("link_attempt[maat_reference]")
    expect(rendered).to include("Back to overview")
  end

  it "renders the offences table" do
    render

    expect(rendered).to have_css("#offence-table")

    expect(rendered).to include("Date")
    expect(rendered).to include("17/10/2019")

    expect(rendered).to include("Offence and legislation")
    expect(rendered).to include("Assisting prisoners to escape")

    expect(rendered).to include("Plea")
    expect(rendered).to include("Not available")

    expect(rendered).to include("Mode of trial")
    expect(rendered).to include("Not available")

    expect(rendered).to include("Verdict")
    expect(rendered).to include("Guilty")
  end
end
