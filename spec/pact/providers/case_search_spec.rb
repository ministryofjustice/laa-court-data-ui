require "pact/rspec"

RSpec.describe "case search", :pact, type: :request do
  include_context "with laa-court-data-adaptor consumer pact"

  let(:user) { create(:user, username: "test_user") }
  let(:case_urn) { "TEST12345" }

  let(:case_search_response_body) do
    {
      total_results: match_any_integer,
      results: [
        {
          prosecution_case_reference: case_urn,
          hearing_summaries: [],
          defendant_summaries: match_each([
            {
              id: match_uuid,
              arrest_summons_number: match_any_string,
              national_insurance_number: match_any_string,
              first_name: match_any_string,
              middle_name: match_any_string,
              last_name: match_any_string,
              date_of_birth: match_any_string,
              offence_summaries: [],
            },
          ]),
        },
      ],
    }
  end

  let(:no_search_results_body) do
    {
      total_results: 0,
      results: [],
    }
  end

  let(:interaction) do
    search_interaction(
      description: "a request to search a case by URN",
      filter: { prosecution_case_reference: case_urn },
      response_body: case_search_response_body,
    )
  end

  before do
    sign_in user
  end

  around do |example|
    VCR.turned_off { example.run }
  end

  def search_interaction(description:, filter:, response_body: case_search_response_body, provider_state: "a prosecution case exists for a URN")
    new_interaction
      .given(provider_state)
      .upon_receiving(description)
      .with_request(
        method: :post,
        path: "/api/internal/v2/prosecution_cases//",
        body: { filter: },
      )
      .will_respond_with(
        status: 200,
        body: response_body,
        headers: { "Content-Type" => "application/vnd.api+json; charset=utf-8" },
      )
  end

  it "searches for and displays the matching case" do
    interaction.execute do |mock_server|
      Cda::ProsecutionCaseSearch.site = mock_server.url

      results = Cda::DefendantSearchService.call(filter: "case_reference", term: case_urn, dob: nil)

      expect(results.count).to eq(1)
    end
  end

  context "when no case matches the URN" do
    let(:interaction) do
      search_interaction(
        description: "a request to search for a case with no matching URN",
        filter: { prosecution_case_reference: case_urn },
        response_body: no_search_results_body,
        provider_state: "no prosecution case exists",
      )
    end

    it "redirects to search when no case is found" do
      interaction.execute do |mock_server|
        Cda::ProsecutionCaseSearch.site = mock_server.url

        results = Cda::DefendantSearchService.call(filter: "case_reference", term: case_urn, dob: nil)

        expect(results).to be_empty
      end
    end
  end

  context "when searching for a defendant by ASN" do
    let(:interaction) do
      search_interaction(
        provider_state: "a prosecution case exists for an ASN",
        description: "a request to search a defendant by ASN",
        filter: { arrest_summons_number: "OC22ZJATX15T" },
      )
    end

    it "searches for and displays the matching defendant" do
      interaction.execute do |mock_server|
        Cda::ProsecutionCaseSearch.site = mock_server.url

        results = Cda::DefendantSearchService.call(filter: "defendant_reference", term: "OC22ZJATX15T", dob: nil)

        expect(results.count).to eq(1)
      end
    end

    context "when no defendant matches" do
      let(:interaction) do
        search_interaction(
          description: "a request to search for a defendant by ASN with no matches",
          filter: { arrest_summons_number: "OC22ZJATX15T" },
          response_body: no_search_results_body,
          provider_state: "no prosecution case exists",
        )
      end

      it "displays a `no results` message" do
        interaction.execute do |mock_server|
          Cda::ProsecutionCaseSearch.site = mock_server.url

          results = Cda::DefendantSearchService.call(filter: "defendant_reference", term: "OC22ZJATX15T", dob: nil)

          expect(results).to be_empty
        end
      end
    end
  end

  context "when searching for a defendant by national insurance number" do
    let(:interaction) do
      search_interaction(
        provider_state: "a prosecution case exists for a national insurance number",
        description: "a request to search a defendant by national insurance number",
        filter: { national_insurance_number: "YE744478B" },
      )
    end

    it "searches for and displays the matching defendant" do
      interaction.execute do |mock_server|
        Cda::ProsecutionCaseSearch.site = mock_server.url

        results = Cda::DefendantSearchService.call(filter: "defendant_reference", term: "YE744478B", dob: nil)

        expect(results.count).to eq(1)
      end
    end

    context "when no defendant matches" do
      let(:interaction) do
        search_interaction(
          description: "a request to search for a defendant by national insurance number with no matches",
          filter: { national_insurance_number: "YE744478B" },
          response_body: no_search_results_body,
          provider_state: "no prosecution case exists",
        )
      end

      it "displays a `no results` message" do
        interaction.execute do |mock_server|
          Cda::ProsecutionCaseSearch.site = mock_server.url

          results = Cda::DefendantSearchService.call(filter: "defendant_reference", term: "YE744478B", dob: nil)

          expect(results).to be_empty
        end
      end
    end
  end

  context "when searching for a defendant by name and date of birth" do
    let(:interaction) do
      search_interaction(
        description: "a request to search a defendant by name and date of birth",
        filter: { name: "Maxie Raynor", date_of_birth: "1973-06-30" },
      )
    end

    it "searches for and displays the matching defendant" do
      interaction.execute do |mock_server|
        Cda::ProsecutionCaseSearch.site = mock_server.url

        results = Cda::DefendantSearchService.call(filter: "defendant_name", term: "Maxie Raynor", dob: "1973-06-30")

        expect(results.count).to eq(1)
      end
    end

    context "when no defendant matches" do
      let(:interaction) do
        search_interaction(
          description: "a request to search for a defendant by name and date of birth with no matches",
          filter: { name: "Maxie Raynor", date_of_birth: "1973-06-30" },
          response_body: no_search_results_body,
          provider_state: "no prosecution case exists",
        )
      end

      it "displays a `no results` message" do
        interaction.execute do |mock_server|
          Cda::ProsecutionCaseSearch.site = mock_server.url

          results = Cda::DefendantSearchService.call(filter: "defendant_name", term: "Maxie Raynor", dob: "1973-06-30")

          expect(results.count).to eq(0)
        end
      end
    end
  end
end
