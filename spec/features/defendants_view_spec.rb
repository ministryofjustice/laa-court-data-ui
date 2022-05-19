# frozen_string_literal: true

RSpec.feature 'defendants view', type: :feature, stub_defendants_uuid_urn_search: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }

  before do
    allow(Feature).to receive(:enabled?).with(:defendants_page).and_return(true)
    sign_in user
  end

  context 'when visting laa_references page' do
    scenario 'laa_references page shows data' do
      visit "laa_references/new?id=#{defendant_id}&urn=#{case_urn}"
      expect(page).to have_title('Maxie Turcotte Raynor')
      expect(page).to have_css('th.govuk-table__header', text: 'Date of birth')
      expect(page).to have_css('th.govuk-table__header', text: 'Case URN')
      expect(page).to have_css('th.govuk-table__header', text: 'NI number')
      expect(page).to have_css('th.govuk-table__header', text: 'ASN')
      expect(page).to have_link('View case')
      expect(page).to have_css('div.govuk-heading-l', text: 'Offences')
      expect(page).to have_css('th.govuk-table__header', text: 'Offence and legislation')
      expect(page).to have_css('th.govuk-table__header', text: 'Plea')
      expect(page).to have_css('th.govuk-table__header', text: 'Mode of trial')
    end
  end

  context 'when visting defendants page' do
    scenario 'defendants page shows data' do
      visit "defendants/#{defendant_id}/edit?urn=#{case_urn}"
      expect(page).to have_title('Maxie Turcotte Raynor')
      expect(page).to have_css('th.govuk-table__header', text: 'Date of birth')
      expect(page).to have_css('th.govuk-table__header', text: 'Case URN')
      expect(page).to have_css('th.govuk-table__header', text: 'NI number')
      expect(page).to have_css('th.govuk-table__header', text: 'ASN')
      expect(page).to have_link('View case')
      expect(page).to have_css('div.govuk-heading-l', text: 'Offences')
      expect(page).to have_css('th.govuk-table__header', text: 'Date')
      expect(page).to have_css('th.govuk-table__header', text: 'Offence and legislation')
      expect(page).to have_css('th.govuk-table__header', text: 'Plea')
      expect(page).to have_css('th.govuk-table__header', text: 'Mode of trial')
    end
  end
end
