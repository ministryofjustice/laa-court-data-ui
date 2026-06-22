# frozen_string_literal: true

RSpec.feature 'defendants view', type: :feature do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:api_url) { "http://localhost:9292/api/internal/v2" }

  before do
    sign_in user

    stub_request(:get, %r{#{api_url}/prosecution_cases/.*/defendants/#{defendant_id}})
      .to_return(
        body: defendant_by_id_fixture,
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )
    stub_request(:get, %r{#{api_url}/prosecution_cases/.*/defendants/#{defendant_id}/offence_history})
      .to_return(
        body: load_json_stub('offence_history.json'),
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )

    stub_request(:get, %r{#{api_url}/prosecution_cases/.*/defendants/500})
      .to_return(
        status: 422,
        body: '{ "error_codes": ["multiple_maats"] }'
      )
  end

  shared_examples 'renders the defendant details' do
    scenario 'shows the defendant data and offences' do
      expect(page).to have_title('Defendant details')
      expect(page).to have_css('th.govuk-table__header', text: 'Date of birth')
      expect(page).to have_css('th.govuk-table__header', text: 'Case URN')
      expect(page).to have_css('th.govuk-table__header', text: 'ASN')
      expect(page).to have_css('th.govuk-table__header', text: 'MAAT number')
      expect(page).to have_link('View case summary')
      expect(page).to have_css('div.govuk-heading-m', text: 'Offences')
      expect(page).to have_css('th.govuk-table__header', text: 'Offence and legislation')
      expect(page).to have_css('th.govuk-table__header', text: 'Plea')
      expect(page).to have_css('th.govuk-table__header', text: 'Mode of trial')
    end

    scenario 'it is accessible', :js do
      expect(page).to be_accessible
    end

    scenario 'show full plea history' do
      click_on 'Reload page with full offence history'
      expect(page).to have_text 'Guilty'
    end
  end

  context 'with an unlinked defendant' do
    let(:defendant_by_id_fixture) { load_json_stub('unlinked_defendant.json') }

    before do
      visit "defendants/#{defendant_id}?urn=#{case_urn}"
    end

    it_behaves_like 'renders the defendant details'

    scenario 'offers the link to court data' do
      expect(page).to have_link('Link MAAT ID')
    end

    context 'when linking is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).and_call_original
        allow(FeatureFlag).to receive(:enabled?).with(:no_linking).and_return(true)
      end

      scenario 'page shows without linking options' do
        visit "defendants/#{defendant_id}?urn=#{case_urn}"
        expect(page).to have_title('Defendant details')
        expect(page).to have_no_link('Link MAAT ID')
      end
    end

    context "when defendant is unavailable" do
      let(:defendant_id) { "500" }

      scenario 'returns to previous page' do
        visit "defendants/#{defendant_id}?urn=#{case_urn}"
        expect(page).to have_current_path '/'
        expect(page).to have_text(
          "The HMCTS record for this defendant cannot be displayed."
        )
      end
    end
  end

  context 'with a linked defendant' do
    let(:defendant_fixture) { load_json_stub('linked/defendant_by_reference_body.json') }
    let(:defendant_by_id_fixture) { load_json_stub('linked_defendant.json') }

    before do
      visit "defendants/#{defendant_id}?urn=#{case_urn}"
    end

    it_behaves_like 'renders the defendant details'

    scenario 'offers the unlink from court data' do
      expect(page).to have_link('Unlink MAAT ID')
    end

    context 'when linking is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).and_call_original
        allow(FeatureFlag).to receive(:enabled?).with(:no_linking).and_return(true)
      end

      scenario 'page shows without linking options' do
        visit "defendants/#{defendant_id}?urn=#{case_urn}"
        expect(page).to have_title('Defendant details')
        expect(page).to have_no_link('Unlink MAAT ID')
      end
    end
  end
end
