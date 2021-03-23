# frozen_string_literal: true

RSpec.feature 'Hearing sorting', type: :feature, vcr: true do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:hearing_id_from_fixture) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  before do
    sign_in user
    visit "prosecution_cases/#{case_urn}"
  end

  def hearing_page_url(page_param, sort_order)
    %r{hearings/.*\?page=#{page_param}&sort_order=#{sort_order}&urn=TEST12345}
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
        expect(rows[0]).to have_link('23/10/2019', href: hearing_page_url(0, 'date_asc'), class: 'govuk-link')
        expect(rows[3]).to have_link('26/10/2019', href: hearing_page_url(3, 'date_asc'), class: 'govuk-link')
        expect(rows[8]).to have_link('31/10/2019', href: hearing_page_url(8, 'date_asc'), class: 'govuk-link')
      end
    end

    scenario 'user can sort by date desc' do
      click_link('Date')
      within :table, 'Hearings' do
        expect(page).to have_link("Date \u25BC", href: prosecution_cases_page_url('date', 'asc'),
                                                 class: 'govuk-link')
        expect(page).to have_link('Hearing type', href: prosecution_cases_page_url('type', 'asc'),
                                                  class: 'govuk-link')
        expect(page).to have_link('Providers attending',
                                  href: prosecution_cases_page_url('provider', 'asc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('31/10/2019', href: hearing_page_url(0, 'date_desc'),
                                                   class: 'govuk-link')
        expect(rows[5]).to have_link('26/10/2019', href: hearing_page_url(5, 'date_desc'),
                                                   class: 'govuk-link')
        expect(rows[8]).to have_link('23/10/2019', href: hearing_page_url(8, 'date_desc'),
                                                   class: 'govuk-link')
      end
    end

    scenario 'user can sort by type desc' do
      click_link('Hearing type')
      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'asc'),
                                          class: 'govuk-link')
        expect(page).to have_link("Hearing type \u25BC", href: prosecution_cases_page_url('type', 'asc'),
                                                         class: 'govuk-link')
        expect(page).to have_link('Providers attending',
                                  href: prosecution_cases_page_url('provider', 'asc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('23/10/2019', href: hearing_page_url(0, 'type_desc'),
                                                   class: 'govuk-link')
        expect(rows[5]).to have_link('31/10/2019', href: hearing_page_url(5, 'type_desc'),
                                                   class: 'govuk-link')
        expect(rows[6]).to have_link('26/10/2019', href: hearing_page_url(6, 'type_desc'),
                                                   class: 'govuk-link')
      end
    end

    scenario 'user can sort by type asc' do
      click_link('Hearing type')
      click_link('Hearing type')

      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'desc'),
                                          class: 'govuk-link')
        expect(page).to have_link("Hearing type \u25B2", href: prosecution_cases_page_url('type', 'desc'),
                                                         class: 'govuk-link')
        expect(page).to have_link('Providers attending',
                                  href: prosecution_cases_page_url('provider', 'desc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('26/10/2019', href: hearing_page_url(0, 'type_asc'),
                                                   class: 'govuk-link')
        expect(rows[5]).to have_link('31/10/2019', href: hearing_page_url(5, 'type_asc'),
                                                   class: 'govuk-link')
        expect(rows[6]).to have_link('23/10/2019', href: hearing_page_url(6, 'type_asc'),
                                                   class: 'govuk-link')
      end
    end

    scenario 'user can sort by provider desc' do
      click_link('Providers attending')
      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'asc'),
                                          class: 'govuk-link')
        expect(page).to have_link('Hearing type', href: prosecution_cases_page_url('type', 'asc'),
                                                  class: 'govuk-link')
        expect(page).to have_link("Providers attending \u25BC",
                                  href: prosecution_cases_page_url('provider', 'asc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[2]).to have_link('31/10/2019', href: hearing_page_url(2, 'provider_desc'),
                                                   class: 'govuk-link')
        expect(rows[3]).to have_link('26/10/2019', href: hearing_page_url(3, 'provider_desc'),
                                                   class: 'govuk-link')
        expect(rows[6]).to have_link('23/10/2019', href: hearing_page_url(6, 'provider_desc'),
                                                   class: 'govuk-link')
      end
    end

    scenario 'user can sort by provider asc' do
      click_link('Providers attending')
      click_link('Providers attending')
      within :table, 'Hearings' do
        expect(page).to have_link('Date', href: prosecution_cases_page_url('date', 'desc'),
                                          class: 'govuk-link')
        expect(page).to have_link('Hearing type', href: prosecution_cases_page_url('type', 'desc'),
                                                  class: 'govuk-link')
        expect(page).to have_link("Providers attending \u25B2",
                                  href: prosecution_cases_page_url('provider', 'desc'), class: 'govuk-link')
        rows = find_all('tbody/tr')
        expect(rows[0]).to have_link('23/10/2019', href: hearing_page_url(0, 'provider_asc'),
                                                   class: 'govuk-link')
        expect(rows[3]).to have_link('26/10/2019', href: hearing_page_url(3, 'provider_asc'),
                                                   class: 'govuk-link')
        expect(rows[8]).to have_link('31/10/2019', href: hearing_page_url(8, 'provider_asc'),
                                                   class: 'govuk-link')
      end
    end
  end
end
