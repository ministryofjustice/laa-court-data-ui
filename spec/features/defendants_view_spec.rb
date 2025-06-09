# frozen_string_literal: true

RSpec.feature 'defendants view', type: :feature do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }

  before do
    sign_in user

    stub_request(:get, %r{#{api_url}/prosecution_cases.*})
      .to_return(
        body: defendant_fixture,
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )

    stub_request(:get, %r{#{api_url}/defendants/#{defendant_id}})
      .to_return(
        body: defendant_by_id_fixture,
        headers: { 'Content-Type' => 'application/vnd.api+json' }
      )

    stub_request(:get, %r{#{api_url}/defendants/500})
      .to_return(
        status: 422,
        body: '{ "error_codes": ["multiple_maats"] }'
      )
  end

  context 'when visting laa_references page' do
    let(:defendant_fixture) { load_json_stub('unlinked/defendant_by_reference_body.json') }
    let(:defendant_by_id_fixture) { load_json_stub('unlinked_defendant.json') }

    scenario 'laa_references page shows data' do
      visit "laa_references/new?id=#{defendant_id}&urn=#{case_urn}"
      expect(page).to have_title('Jammy Dodger')
      expect(page).to have_css('th.govuk-table__header', text: 'Date of birth')
      expect(page).to have_css('th.govuk-table__header', text: 'Case URN')
      expect(page).to have_css('th.govuk-table__header', text: 'NI number')
      expect(page).to have_css('th.govuk-table__header', text: 'ASN')
      expect(page).to have_css('th.govuk-table__header', text: 'MAAT number')
      expect(page).to have_link('View case')
      expect(page).to have_css('div.govuk-heading-l', text: 'Offences')
      expect(page).to have_css('th.govuk-table__header', text: 'Offence and legislation')
      expect(page).to have_css('th.govuk-table__header', text: 'Plea')
      expect(page).to have_css('th.govuk-table__header', text: 'Mode of trial')
      expect(page).to have_content('Create link to court data')
    end

    context 'when linking is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).with(:maintenance_mode).and_return(false)
        allow(FeatureFlag).to receive(:enabled?).with(:no_linking).and_return(true)
      end

      scenario 'page shows without linking options' do
        visit "laa_references/new?id=#{defendant_id}&urn=#{case_urn}"
        expect(page).to have_title('Jammy Dodger')
        expect(page).to have_no_content('Create link to court data')
      end
    end

    context "when defendant is unavailable" do
      let(:defendant_id) { "500" }

      scenario 'laa_references page returns to previous page' do
        visit "laa_references/new?id=#{defendant_id}&urn=#{case_urn}"
        expect(page).to have_current_path '/'
        expect(page).to have_content "The HMCTS Common Platform record for this defendant is corrupted"
      end
    end
  end

  context 'when visting defendants page' do
    let(:defendant_fixture) { load_json_stub('linked/defendant_by_reference_body.json') }
    let(:defendant_by_id_fixture) { load_json_stub('linked_defendant.json') }

    scenario 'defendants page shows data' do
      visit "defendants/#{defendant_id}/edit?urn=#{case_urn}"
      expect(page).to have_title('Jammy Dodger')
      expect(page).to have_css('th.govuk-table__header', text: 'Date of birth')
      expect(page).to have_css('th.govuk-table__header', text: 'Case URN')
      expect(page).to have_css('th.govuk-table__header', text: 'NI number')
      expect(page).to have_css('th.govuk-table__header', text: 'ASN')
      expect(page).to have_css('th.govuk-table__header', text: 'MAAT number')
      expect(page).to have_link('View case')
      expect(page).to have_css('div.govuk-heading-l', text: 'Offences')
      expect(page).to have_css('th.govuk-table__header', text: 'Date')
      expect(page).to have_css('th.govuk-table__header', text: 'Offence and legislation')
      expect(page).to have_css('th.govuk-table__header', text: 'Plea')
      expect(page).to have_css('th.govuk-table__header', text: 'Mode of trial')
      expect(page).to have_content('Remove link to court data')
    end

    context 'when linking is disabled' do
      before do
        allow(FeatureFlag).to receive(:enabled?).with(:maintenance_mode).and_return(false)
        allow(FeatureFlag).to receive(:enabled?).with(:no_linking).and_return(true)
      end

      scenario 'page shows without linking options' do
        visit "defendants/#{defendant_id}/edit?urn=#{case_urn}"
        expect(page).to have_title('Jammy Dodger')
        expect(page).to have_no_content('Remove link to court data')
      end
    end
  end
end
