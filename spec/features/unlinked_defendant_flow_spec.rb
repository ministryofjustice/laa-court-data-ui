# frozen_string_literal: true

RSpec.feature 'Unlinked defendant page flow', type: :feature, vcr: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'MOGUERBXIZ' }
  let(:defendant_nino) { 'HR669639D' }

  before do
    sign_in user
  end

  scenario 'user views prosecution case details' do
    when_viewing_case(case_urn)
    then_case_view_displayed
    then_defendant_list_displayed

    click_link('Josefa Franecki')
    then_defendant_view_displayed_for('Josefa Franecki')
  end

  scenario 'user navigates from case to defendant view' do
    when_viewing_case(case_urn)
    then_case_view_displayed
    click_link('Josefa Franecki')
    then_defendant_view_displayed_for('Josefa Franecki')
  end

  scenario 'user views defendant details' do
    when_viewing_defendant(defendant_nino)
    then_defendant_view_displayed_for('Josefa Franecki')
    then_has_defendant_details
    then_has_offence_details
    then_has_laa_reference_forms
  end

  def when_viewing_case(case_urn)
    visit "prosecution_cases/#{case_urn}"
  end

  def then_case_view_displayed
    expect(page).to have_css('h1', text: 'MOGUERBXIZ')
    expect(page).to have_css('.govuk-heading-m', text: 'Defendants')
  end

  def when_viewing_defendant(defendant_nino_or_asn)
    visit "defendants/#{defendant_nino_or_asn}"
  end

  def then_defendant_view_displayed_for(name)
    expect(page).to have_css('h1', text: name)
    expect(page).to have_css('.govuk-table', count: 2)
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
      end
    end
  end

  def then_has_defendant_details
    defendant_details = page.all('.govuk-table')[0]

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

  def then_has_offence_details
    offence_details = page.all('.govuk-table')[1]

    within offence_details do
      expect(page).to have_css('.govuk-table__header', text: 'Offence')
      expect(page).to have_css('.govuk-table__header', text: 'Plea')
      expect(page).to have_css('.govuk-table__header', text: 'Mode of trial')
    end
  end

  def then_has_laa_reference_forms
    expect(page).to have_field('MAAT ID')
    expect(page).to have_button('Create link to court data')
  end
end
