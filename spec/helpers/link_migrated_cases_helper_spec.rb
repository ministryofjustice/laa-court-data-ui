# frozen_string_literal: true

RSpec.describe LinkMigratedCasesHelper, type: :helper do
  describe "#column_config" do
    it "returns configuration for a known column" do
      expect(helper.column_config("case_urn")).to include(:width, :sortable, :i18n_key)
    end

    it "returns nil for unknown column" do
      expect(helper.column_config("non_existent")).to be_nil
    end
  end

  describe "#formatted_process_errors" do
    it "returns nil when there are no errors" do
      expect(helper.formatted_process_errors(nil)).to be_nil
    end

    it "returns the message of a single step" do
      err = { "maat" => { "message" => "MAAT application not found" } }
      expect(helper.formatted_process_errors(err)).to eq("MAAT application not found")
    end

    it "formats error and message of a step" do
      err = { "maat" => { "error" => 500, "message" => "Internal Server Error" } }
      expect(helper.formatted_process_errors(err)).to eq("500 - Internal Server Error")
    end

    it "joins the errors of several steps" do
      err = {
        "maat" => { "error" => 500, "message" => "Internal Server Error" },
        "common_platform" => { "message" => "Case not found on Common Platform" },
      }
      expect(helper.formatted_process_errors(err))
        .to eq("500 - Internal Server Error; Case not found on Common Platform")
    end

    it "skips steps without error or message" do
      err = { "maat" => {}, "common_platform" => { "message" => "Case not found on Common Platform" } }
      expect(helper.formatted_process_errors(err)).to eq("Case not found on Common Platform")
    end
  end

  describe "#link_maat_id_url" do
    it "returns a link to the migrated case linking page with the urn param" do
      allow(helper).to receive(:link_link_migrated_case_path)
        .with("12345678-1234-1234-1234-123456789012")
        .and_return("/link/12345678-1234-1234-1234-123456789012")

      result = helper.link_maat_id_url("12345678-1234-1234-1234-123456789012")
      expect(result).to include("Link MAAT ID")
      expect(result).to include('href="/link/12345678-1234-1234-1234-123456789012"')
      expect(result).to include("govuk-link")
    end
  end

  describe "#case_urn_new_tab_url" do
    it "returns a link that opens the case urn in a new tab" do
      allow(helper).to receive(:prosecution_case_path).with("URN-1").and_return("/prosecution_cases/URN-1")

      result = helper.case_urn_new_tab_url("URN-1")
      expect(result).to include('href="/prosecution_cases/URN-1"')
      expect(result).to include('target="_blank"')
      expect(result).to include('rel="noopener"')
      expect(result).to include("govuk-link govuk-link--no-visited-state")
    end
  end

  describe "#column_value" do
    let(:base_case) do
      {
        "id" => "12345678-1234-1234-1234-123456789012",
        "defendant_first_name" => "John",
        "defendant_last_name" => "Doe",
        "case_urn" => "URN-1",
        "process_errors" => { "maat" => { "error" => "E", "message" => "M" } },
        "defendant_id" => 555,
        "linked_at" => "2024-02-01T12:00:00Z",
        "defendant_date_of_birth" => "2024-02-02T12:00:00Z",
        "x" => "y",
      }
    end

    before do
      allow(helper).to receive(:link_defendant_path).and_return("/link/555?urn=URN-1")
    end

    it "joins defendant first and last name" do
      expect(helper.column_value("defendant_name", base_case)).to eq("John Doe")
    end

    it "returns linked_at for auto_linked_at column" do
      expect(helper.column_value("auto_linked_at", base_case)).to eq("01/02/2024")
    end

    it "returns case_urn for case_urn_new_tab column" do
      expected_html = <<~HTML.chomp
        <div class="tags"><a class="govuk-link govuk-link--no-visited-state" target="_blank" rel="noopener" href="/prosecution_cases/URN-1">URN-1</a></div>
      HTML

      expect(helper.column_value("case_urn_new_tab", base_case)).to eq(expected_html)
    end

    it "uses formatted_process_errors for reason_for_man_linking column" do
      allow(helper).to receive(:formatted_process_errors).and_call_original

      expect(helper.column_value("reason_for_man_linking", base_case)).to eq("E - M")
      expect(helper).to have_received(:formatted_process_errors).with(base_case["process_errors"])
    end

    it "returns a link for link_maat_id column" do
      result = helper.column_value("action", base_case)
      expect(result).to include('href="/link_migrated_cases/12345678-1234-1234-1234-123456789012/link"')
      expect(result).to include("Link MAAT ID")
    end

    it "formats linked_at values for the linked_at column" do
      expect(helper.column_value("linked_at", base_case)).to eq("01/02/2024")
    end

    it "formats defendant_date_of_birth values for the defendant_date_of_birth column" do
      expect(helper.column_value("defendant_date_of_birth", base_case)).to eq("2 Feb 2024")
    end

    it "falls back to raw value for other columns" do
      expect(helper.column_value("x", base_case)).to eq("y")
    end
  end

  describe "#page_url" do
    it "calls link_migrated_cases_path with page and current params" do
      allow(helper).to receive_messages(params: ActionController::Parameters.new(tab: "xx",
                                                                                 sort_column: "sc",
                                                                                 sort_direction: "desc"),
                                        link_migrated_cases_path: "/dummy")

      helper.page_url(3)
      expect(helper).to have_received(:link_migrated_cases_path).with(page: 3, tab: "xx", sort_column: "sc",
                                                                      sort_direction: "desc")
    end
  end

  describe "#migrated_cases_sorter_header" do
    it "delegates to sorter_header with migrated cases sort keys and translated label" do
      allow(helper).to receive_messages(params: ActionController::Parameters.new(tab: "all"),
                                        link_migrated_cases_path: "/link_migrated_cases?tab=all",
                                        t: "Case URN")
      allow(helper).to receive(:sorter_header).and_return("<th>Case URN</th>")

      result = helper.migrated_cases_sorter_header("case_urn", "case_urn")

      expect(helper).to have_received(:sorter_header).with(
        path: "/link_migrated_cases?tab=all",
        column: "case_urn",
        direction_key: :sort_direction,
        column_key: :sort_column,
        label: "Case URN",
        default_sort_column: "case_urn",
      )
      expect(result).to eq("<th>Case URN</th>")
    end
  end
end
