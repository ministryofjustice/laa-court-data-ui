# frozen_string_literal: true

RSpec.feature 'Hearing sorting', :vcr, type: :feature do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:hearing_id_from_fixture) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  before do
    sign_in user
    visit "prosecution_cases/#{case_urn}"
  end

  def hearing_page_url(day)
    %r{hearings/.*\?day=#{day}&urn=TEST12345}
  end

  def prosecution_cases_page_url(column, direction)
    %r{prosecution_cases/.*\?column=#{column}&direction=#{direction}}
  end

  context 'when viewing case details' do
    scenario 'user can see links with hearing table sorted by date_asc' do
      within :table, 'Hearings' do
        expect(page).to have_link("Date \u25B2", href: prosecution_cases_page_url('date', 'desc'),
                                                 class: 'govuk-link')
        expect(page).to have_link('Hearing type', href: prosecution_cases_page_url('type', 'desc'),
                                                  class: 'govuk-link')
        expect(page).to have_link('Providers attending',
                                  href: prosecution_cases_page_url('provider', 'desc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('23/10/2019', href: hearing_page_url('2019-10-23'),
                                                   class: 'govuk-link')
        expect(rows[1]).to have_link('26/10/2019', href: hearing_page_url('2019-10-26'),
                                                   class: 'govuk-link')
        expect(rows[2]).to have_link('27/10/2019', href: hearing_page_url('2019-10-27'),
                                                   class: 'govuk-link')
      end
    end

    scenario 'user can sort by date desc' do
      click_link_or_button('Date')
      within :table, 'Hearings' do
        expect(page).to have_link("Date \u25BC", href: prosecution_cases_page_url('date', 'asc'),
                                                 class: 'govuk-link')
        expect(page).to have_link('Hearing type', href: prosecution_cases_page_url('type', 'asc'),
                                                  class: 'govuk-link')
        expect(page).to have_link('Providers attending',
                                  href: prosecution_cases_page_url('provider', 'asc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('02/11/2019', class: 'govuk-link')
        expect(rows[5]).to have_link('26/10/2019', class: 'govuk-link')
        expect(rows[6]).to have_link('23/10/2019', class: 'govuk-link')
      end
    end

    scenario 'user clicks to sort by type desc' do
      click_link_or_button('Hearing type')
      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'asc'),
                                          class: 'govuk-link')
        expect(page).to have_link("Hearing type \u25BC", href: prosecution_cases_page_url('type', 'asc'),
                                                         class: 'govuk-link')
        expect(page).to have_link('Providers attending',
                                  href: prosecution_cases_page_url('provider', 'asc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('26/10/2019', class: 'govuk-link')
        expect(rows[0]).to have_text('Pre-Trial Review (PTR)')
        expect(rows[5]).to have_link('01/11/2019', class: 'govuk-link')
        expect(rows[5]).to have_text('Application to Break Fixture (BFA)')
        expect(rows[6]).to have_link('02/11/2019', class: 'govuk-link')
        expect(rows[6]).to have_text('Application to Break Fixture (BFA)')
      end
    end

    scenario 'user clicks (twice) to sort by type asc' do
      click_link_or_button('Hearing type')
      click_link_or_button('Hearing type')

      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'desc'),
                                          class: 'govuk-link')
        expect(page).to have_link("Hearing type \u25B2", href: prosecution_cases_page_url('type', 'desc'),
                                                         class: 'govuk-link')
        expect(page).to have_link('Providers attending',
                                  href: prosecution_cases_page_url('provider', 'desc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('31/10/2019', class: 'govuk-link')
        expect(rows[0]).to have_text('Application to Break Fixture (BFA)')
        expect(rows[5]).to have_link('27/10/2019', class: 'govuk-link')
        expect(rows[5]).to have_text('Pre-Trial Review (PTR)')
        expect(rows[6]).to have_link('28/10/2019', class: 'govuk-link')
        expect(rows[6]).to have_text('Pre-Trial Review (PTR)')
      end
    end

    scenario 'user clicks to sort by provider desc' do
      click_link_or_button('Providers attending')
      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'asc'),
                                          class: 'govuk-link')
        expect(page).to have_link('Hearing type', href: prosecution_cases_page_url('type', 'asc'),
                                                  class: 'govuk-link')
        expect(page).to have_link("Providers attending \u25BC",
                                  href: prosecution_cases_page_url('provider', 'asc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[2]).to have_link('28/10/2019', class: 'govuk-link')
        expect(rows[2]).to have_text('Pre-Trial Review (PTR)')
        expect(rows[3]).to have_link('31/10/2019', class: 'govuk-link')
        expect(rows[3]).to have_text('Application to Break Fixture (BFA)')
        expect(rows[6]).to have_link('23/10/2019', class: 'govuk-link')
        expect(rows[6]).to have_text('Mention - Defendant to Attend (MDA)')
      end
    end

    scenario 'user clicks (twice) to sort by provider asc' do
      click_link_or_button('Providers attending')
      click_link_or_button('Providers attending')
      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'desc'),
                                          class: 'govuk-link')
        expect(page).to have_link('Hearing type', href: prosecution_cases_page_url('type', 'desc'),
                                                  class: 'govuk-link')
        expect(page).to have_link("Providers attending \u25B2",
                                  href: prosecution_cases_page_url('provider', 'desc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('23/10/2019', class: 'govuk-link')
        expect(rows[0]).to have_text('Mention - Defendant to Attend (MDA)')
        expect(rows[3]).to have_link('02/11/2019', class: 'govuk-link')
        expect(rows[3]).to have_text('Application to Break Fixture (BFA)')
        expect(rows[6]).to have_link('28/10/2019', class: 'govuk-link')
        expect(rows[6]).to have_text('Pre-Trial Review (PTR)')
      end
    end
  end
end
