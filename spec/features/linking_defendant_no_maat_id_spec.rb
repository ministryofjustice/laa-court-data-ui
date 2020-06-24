# frozen_string_literal: true

RSpec.describe 'Linking a defendant with no MAAT id', type: :feature, stub_unlinked: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_nino) { 'MR610691B' }
  let(:defendant_asn) { 'LYDAO0SB7S2P' }
  let(:defendant_name) { 'Hobert Brown' }

  before do
    sign_in user
  end

  scenario 'user links defendant details with no maat id', :stub_link_success do
    visit "prosecution_cases/#{case_urn}"
    click_link('Hobert Brown')
    expect(page).to have_text('The MAAT id is missing')
    find(:xpath, "//details[@class='govuk-details']", text: 'The MAAT id is missing').click
    expect(page).to have_button('Create link without MAAT ID')
    click_button 'Create link without MAAT ID'
    stub_linked_defendant
    expect(page).to have_govuk_flash(:notice, text: 'You have successfully linked to the court data source')
  end

  def stub_linked_defendant
    stub_request(
      :get,
      %r{http.*/api/internal/v1/prosecution_cases\?filter.*}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end
end
