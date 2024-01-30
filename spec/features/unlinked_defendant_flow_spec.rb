# frozen_string_literal: true

RSpec.feature 'Unlinked defendant page flow', :stub_unlinked, type: :feature do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_name) { 'Jammy Dodger' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:hearing_day) { '23/10/2019' }

  before do
    sign_in user
  end

  scenario 'user views prosecution case details' do
    when_viewing_case(case_urn)
    then_case_view_displayed
    then_defendant_list_displayed

    click_link_or_button('Jammy Dodger')
    then_defendant_view_displayed_for(defendant_name)
  end

  scenario 'user navigates from case to defendant view' do
    when_viewing_case(case_urn)
    then_case_view_displayed
    click_link_or_button(defendant_name)
    then_defendant_view_displayed_for(defendant_name)
    then_unlinked_defendant_page_displayed
  end

  scenario 'user navigates from case to hearings view', :stub_hearing do
    when_viewing_case(case_urn)
    then_case_view_displayed
    click_link_or_button(hearing_day)
    then_hearing_view_displayed_for(hearing_day)
  end

  scenario 'user views defendant details' do
    when_viewing_defendant(defendant_id)
    then_defendant_view_displayed_for(defendant_name)
    then_unlinked_defendant_page_displayed
  end

  scenario 'user links defendant', :stub_v2_link_success do
    when_viewing_defendant(defendant_id)
    then_defendant_view_displayed_for(defendant_name)
    then_unlinked_defendant_page_displayed
    when_user_links_maat_reference_on_defendant
    then_linked_defendant_page_displayed
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

  def when_user_links_maat_reference_on_defendant
    stub_linked_defendant
    fill_in 'MAAT ID', with: '2123456'
    click_link_or_button 'Create link to court data'
  end

  def then_unlinked_defendant_page_displayed
    then_has_defendant_details(table_number: 0)
    then_has_offence_details(table_number: 1)
    then_has_laa_reference_form
  end

  def then_linked_defendant_page_displayed
    expect(page).to have_govuk_flash(:notice, text: 'You have successfully linked to the court data source')
    then_has_defendant_details(table_number: 0)
    then_has_offence_details(table_number: 1)
    expect(page).to have_govuk_detail_summary('Remove link to court data')
    expect(page).to have_govuk_warning('Removing the link will stop hearing updates being received')
  end

  def when_viewing_case(case_urn)
    visit "prosecution_cases/#{case_urn}"
  end

  def then_case_view_displayed
    has_case_heading
    then_defendant_list_displayed
    then_hearing_summary_list_displayed
  end

  def has_case_heading
    expect(page).to have_css('h1', text: 'TEST12345')
    expect(page).to have_css('.govuk-caption-xl', text: 'Case')
  end

  def when_viewing_defendant(defendant_id)
    visit new_laa_reference_path(id: defendant_id, urn: case_urn)
  end

  def then_defendant_view_displayed_for(name)
    expect(page).to have_css('h1', text: name)
    expect(page).to have_css('.govuk-caption-xl', text: 'Defendant')
    expect(page).to have_css('.govuk-table', minimum: 2)
  end

  def then_hearing_summary_list_displayed
    has_hearing_summary_table
    has_hearing_summary_table_headers
    has_hearing_summary_table_row_cells
  end

  def has_hearing_summary_table
    expect(page).to have_css('.govuk-heading-l', text: 'Hearings')
    expect(page).to have_table('Hearings')
  end

  def has_hearing_summary_table_headers
    within :table, 'Hearings' do
      expect(page).to have_css('.govuk-table__header', text: 'Date')
      expect(page).to have_css('.govuk-table__header', text: 'Hearing type')
      expect(page).to have_css('.govuk-table__header', text: 'Providers attending')
    end
  end

  def has_hearing_summary_table_row_cells
    within :table, 'Hearings' do
      rows = find_all('tbody .govuk-table__row')
      rows.each do |row|
        cells = row.all('.govuk-table__cell')
        expect(cells[0]).to have_link(nil, href: %r{/hearings/.*})
        expect(cells[1].text).to be_a String
        expect(cells[2]).to have_text(/\(.*counsel.*\)/)
      end
    end
  end

  def then_hearing_view_displayed_for(hearing_day)
    has_hearing_heading(hearing_day)
    has_hearing_details
    has_attendee_details
    has_hearing_event_table
    has_hearing_event_table_headers
  end

  def has_hearing_heading(hearing_day)
    expect(page).to have_css('.govuk-caption-xl', text: 'Hearing')
    expect(page).to have_css('h1.govuk-heading-xl', text: hearing_day)
  end

  def has_hearing_details
    expect(page).to have_css('.govuk-heading-l', text: 'Details')
    expect(page).to have_css('.govuk-heading-s', text: 'Hearing type')
    expect(page).to have_css('.govuk-heading-s', text: 'Court')
    expect(page).to have_css('.govuk-heading-s', text: 'Time listed')
  end

  def has_attendee_details
    expect(page).to have_css('.govuk-heading-l', text: 'Attendees')
    expect(page).to have_css('.govuk-heading-s', text: 'Defendants')
    expect(page).to have_css('.govuk-heading-s', text: 'Defence advocate')
    expect(page).to have_css('.govuk-heading-s', text: 'Prosecution advocate')
    expect(page).to have_css('.govuk-heading-s', text: 'Judge')
  end

  def has_hearing_event_table
    expect(page).to have_table('Hearing events')
  end

  def has_hearing_event_table_headers
    within :table, 'Hearing events' do
      expect(page).to have_css('.govuk-table__header', text: 'Time')
      expect(page).to have_css('.govuk-table__header', text: 'Event')
    end
  end

  def then_defendant_list_displayed
    has_defendant_table
    has_defendant_table_headers
    has_defendant_table_row_cells
  end

  def has_defendant_table
    expect(page).to have_css('.govuk-heading-l', text: 'Defendant')
    expect(page).to have_table('Defendants')
  end

  def has_defendant_table_headers
    within :table, 'Defendants' do
      expect(page).to have_css('.govuk-table__header', text: 'Name')
      expect(page).to have_css('.govuk-table__header', text: 'Date of birth')
      expect(page).to have_css('.govuk-table__header', text: 'MAAT number')
    end
  end

  def has_defendant_table_row_cells
    within :table, 'Defendants' do
      rows = find_all('tbody .govuk-table__row')
      rows.each do |row|
        cells = row.all('.govuk-table__cell')
        expect(cells[0]).to have_link(nil, href: %r{/laa_references/.*})
        expect(cells[1].text).to match(%r{[0-3][0-9]/[0-1][0-9]/[1-2][0|9](?:[0-9]{2})?})
        expect(cells[2].text).to eql('Not linked').or match(/\A[0-9]{7}\z/)
      end
    end
  end

  def then_has_defendant_details(table_number: 0)
    defendant_details = page.all('.govuk-table')[table_number]

    within defendant_details do
      rows = page.all('.govuk-table__row')
      expect(rows[0]).to have_content('Date of birth')
      expect(rows[0]).to have_content(%r{[0-3][0-9]/[0-1][0-9]/[1-2][0|9](?:[0-9]{2})?})
      expect(rows[1]).to have_content('Case URN')
      expect(rows[2]).to have_content('NI number')
      expect(rows[3]).to have_content('ASN')
    end

    expect(page).to have_link('View case', href: %r{/prosecution_cases/.*})
  end

  def then_has_offence_details(table_number: 1)
    offence_details = page.all('.govuk-table')[table_number]

    within offence_details do
      expect(page).to have_css('.govuk-table__header', text: 'Offence and legislation')
      expect(page).to have_css('.govuk-table__header', text: 'Plea')
      expect(page).to have_css('.govuk-table__header', text: 'Mode of trial')
      expect(page).to have_css('.govuk-table__cell', text: 'Not guilty on 12/04/2020')
      expect(page).to have_css('.govuk-table__cell', text: /Indictable only:.*Defendant elects trial by jury/)
    end
  end

  def then_has_laa_reference_form
    expect(page).to have_field('MAAT ID')
    expect(page).to have_button('Create link to court data')
  end
end
