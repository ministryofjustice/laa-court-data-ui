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
        status: 422
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
    end

    scenario 'laa_references page returns to previous page' do
      visit "laa_references/new?id=500&urn=#{case_urn}"
      expect(page).to have_current_path '/'
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
    end
  end
end
