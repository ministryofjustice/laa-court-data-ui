# frozen_string_literal: true

RSpec.describe "Xhibit case number search", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it "renders searches#new to Search by Xhibit case number" do
    get "/searches/new", params: { search: { filter: :xhibit_case_number } }
    expect(response.body).to include("Xhibit case reference")
  end

  context "when posting a query", :stub_defendants_case_search do
    before do
      post "/searches", params: { search: { term: "T20254007", filter: :xhibit_case_number } }
    end

    it "accepts query parameter" do
      expect(response).to have_http_status :ok
    end

    it "sends the Xhibit case number to CDA" do
      expect(
        a_request(:post, %r{/v2/prosecution_cases})
          .with(body: hash_including("filter" => { "xhibit_case_number" => "T20254007" })),
      ).to have_been_made
    end

    it "renders results/_defendant" do
      expect(response.body).to include("4 search results")
    end

    it "shows the Xhibit ref column" do
      expect(Capybara.string(response.body)).to have_css(".govuk-table__header", text: "Xhibit ref")
    end
  end

  context "when the term is lowercase", :stub_defendants_case_search do
    before do
      post "/searches", params: { search: { term: "t20254007", filter: :xhibit_case_number } }
    end

    it "shows the Xhibit ref uppercased" do
      expect(Capybara.string(response.body)).to have_css(".govuk-table__cell", text: "T20254007")
    end
  end

  context "when no results", :stub_no_v2_case_results do
    before do
      post "/searches", params: { search: { term: "T20259999", filter: :xhibit_case_number } }
    end

    it "renders results/_none template" do
      expect(response.body).to include("Check you have entered the details correctly")
    end

    it "shows the not migrated guidance" do
      expect(response.body).to include("The case might not have been migrated yet")
    end
  end
end
