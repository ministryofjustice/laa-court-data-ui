# frozen_string_literal: true

RSpec.describe 'Linking a defendant', :stub_unlinked, :stub_hearing_summary, type: :feature do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:case_reference) { case_urn }
  let(:defendant_name) { 'Jammy Dodger' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }

  let(:linked_defendant_stub) do
    stub_request(
      :get,
      %r{http.*/api/internal/v1/defendants/#{defendant_id}}
    ).to_return(
      status: 200,
      body: load_json_stub('unlinked_defendant.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  before do
    sign_in user
  end

  scenario 'user links defendant details', :stub_v2_link_success do
    visit "prosecution_cases/#{case_urn}"
    click_link_or_button('Jammy Dodger')
    fill_in "MAAT ID", with: "1234567"
    click_link_or_button 'Create link to court data'
    linked_defendant_stub
    expect(page).to have_govuk_flash(:notice, text: 'You have successfully linked to the court data source')
  end

  scenario 'user links defendant details with no maat id', :stub_v2_link_success do
    visit "prosecution_cases/#{case_urn}"
    click_link_or_button('Jammy Dodger')
    expect(page).to have_text('The MAAT id is missing')
    find(:xpath, "//details[@class='govuk-details']", text: 'The MAAT id is missing').click
    expect(page).to have_button('Create link without MAAT ID')
    click_link_or_button 'Create link without MAAT ID'
    linked_defendant_stub
    expect(page).to have_govuk_flash(:notice, text: 'You have successfully linked to the court data source')
  end

  scenario 'CDA errors out', :stub_v2_link_cda_failure do
    visit "prosecution_cases/#{case_urn}"
    click_link_or_button('Jammy Dodger')
    fill_in "MAAT ID", with: "1234567"
    click_link_or_button 'Create link to court data'
    expect(page).to have_govuk_flash(:alert, text: 'HMCTS Common Platform could not be reached.')
  end
end
