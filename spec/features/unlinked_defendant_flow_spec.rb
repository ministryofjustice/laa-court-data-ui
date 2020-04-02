# frozen_string_literal: true

RSpec.feature 'Unlinked defendant page flow', type: :feature, stub_unlinked: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_nino) { 'JC123456A' }
  let(:defendant_asn) { '0TSQT1LMI7CR' }
  let(:defendant_name) { 'Jammy Dodger' }

  before do
    sign_in user
  end

  scenario 'user views prosecution case details' do
    when_viewing_case(case_urn)
    then_case_view_displayed
    then_defendant_list_displayed

    click_link('Jammy Dodger')
    then_defendant_view_displayed_for(defendant_name)
  end

  scenario 'user navigates from case to defendant view' do
    when_viewing_case(case_urn)
    then_case_view_displayed
    click_link(defendant_name)
    then_defendant_view_displayed_for(defendant_name)
    then_unlinked_defendant_page_displayed
  end

  scenario 'user views defendant details' do
    when_viewing_defendant(defendant_nino)
    then_defendant_view_displayed_for(defendant_name)
    then_unlinked_defendant_page_displayed
  end

  scenario 'user links defendant', :stub_link_success do
    when_viewing_defendant(defendant_nino)
    then_defendant_view_displayed_for(defendant_name)
    then_unlinked_defendant_page_displayed
    when_user_links_maat_reference_on_defendant
    then_linked_defendant_page_displayed
  end

  def stub_linked_defendant
    stub_request(
      :get,
      %r{http.*\/api\/internal\/v1\/prosecution_cases\?filter.*}
    ).to_return(
      status: 200,
      body: load_json_stub('linked/defendant_by_reference_body.json'),
      headers: { 'Content-Type' => 'application/vnd.api+json' }
    )
  end

  def when_user_links_maat_reference_on_defendant
    stub_linked_defendant
    fill_in 'MAAT ID', with: '2123456'
    click_button 'Create link to court data'
  end

  def then_unlinked_defendant_page_displayed
    then_has_defendant_details(table_number: 0)
    then_has_offence_details(table_number: 1)
    then_has_laa_reference_form
  end

  def then_linked_defendant_page_displayed
    expect(page).to have_govuk_flash(:notice, text: 'You have successfully linked to the court data source')
    then_has_defendant_details(table_number: 0)
    then_has_representation_order_details(table_number: 1)
    then_has_offence_details(table_number: 2)
    expect(page).to have_link('Remove link to court data')
    expect(page).to have_content('Removing the link will stop hearing updates being received')
  end

  def when_viewing_case(case_urn)
    visit "prosecution_cases/#{case_urn}"
  end

  def then_case_view_displayed
    expect(page).to have_css('h1', text: 'TEST12345')
    expect(page).to have_css('.govuk-heading-m', text: 'Defendants')
  end

  def when_viewing_defendant(defendant_nino_or_asn)
    visit "defendants/#{defendant_nino_or_asn}"
  end

  def then_defendant_view_displayed_for(name)
    expect(page).to have_css('h1', text: name)
    expect(page).to have_css('.govuk-table', minimum: 2)
  end

  def then_defendant_list_displayed
    within 'thead.govuk-table__head' do
      expect(page).to have_css('.govuk-table__header', text: 'Name')
      expect(page).to have_css('.govuk-table__header', text: 'Date of birth')
      expect(page).to have_css('.govuk-table__header', text: 'MAAT number')
    end

    within 'tbody.govuk-table__body' do
      rows = page.all('.govuk-table__row')
      rows.each do |row|
        cells = row.all('.govuk-table__cell')
        expect(cells[0]).to have_link(nil, href: %r{\/defendants\/.*})
        expect(cells[1].text).to match(%r{[0-3][0-9]\/[0-1][0-9]\/[1-2][0|9](?:[0-9]{2})?})
        expect(cells[2].text).to eql 'Not linked'
      end
    end
  end

  def then_has_defendant_details(table_number: 0)
    defendant_details = page.all('.govuk-table')[table_number]

    within defendant_details do
      rows = page.all('.govuk-table__row')
      expect(rows[0]).to have_content('Date of birth')
      expect(rows[0]).to have_content(%r{[0-3][0-9]\/[0-1][0-9]\/[1-2][0|9](?:[0-9]{2})?})

      expect(rows[1]).to have_content('Case URN')
      expect(rows[1]).to have_link(nil, href: %r{\/prosecution_cases\/.*})

      expect(rows[2]).to have_content('NI number')
      expect(rows[3]).to have_content('ASN')
    end
  end

  def then_has_offence_details(table_number: 1)
    offence_details = page.all('.govuk-table')[table_number]

    within offence_details do
      expect(page).to have_css('.govuk-table__header', text: 'Offence')
      expect(page).to have_css('.govuk-table__header', text: 'Plea')
      expect(page).to have_css('.govuk-table__header', text: 'Mode of trial')
    end
  end

  def then_has_representation_order_details(table_number: 1)
    representation_order_details = page.all('.govuk-table')[table_number]

    within representation_order_details do
      expect(page).to have_css('.govuk-table__header', text: 'Date granted')
      expect(page).to have_css('.govuk-table__header', text: 'MAAT number')
      expect(page).to have_css('.govuk-table__header', text: 'Provider')
    end
  end

  def then_has_laa_reference_form
    expect(page).to have_field('MAAT ID')
    expect(page).to have_button('Create link to court data')
  end
end
