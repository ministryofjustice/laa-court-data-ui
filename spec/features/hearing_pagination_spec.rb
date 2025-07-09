# frozen_string_literal: true

RSpec.feature 'Hearing pagination', :vcr, type: :feature do
  let(:user) { create(:user) }
  let(:case_urn) { 'TEST12345' }
  let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
  let(:hearing_id_from_fixture) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  before do
    sign_in user
    visit "prosecution_cases/#{case_urn}"
  end

  def hearing_page_url(page_param)
    %r{hearings/.*\?column=date&direction=asc&page=#{page_param}&urn=TEST12345}
  end

  context 'when viewing case details' do
    scenario 'user can see links to hearing pages' do
      within :table, 'Hearings' do
        expect(page).to have_link('23 October 2019', href: hearing_page_url(0), class: 'govuk-link')
        expect(page).to have_link('26 October 2019', href: hearing_page_url(1), class: 'govuk-link')
        expect(page).to have_link('31 October 2019', href: hearing_page_url(4), class: 'govuk-link')
      end
    end

    scenario 'user can navigate to a paginated hearing page' do
      click_link_or_button('23 October 2019')
      expect(page).to have_current_path(hearing_page_url(0), url: true)
    end
  end

  context 'when on hearing page' do
    context 'with first hearing\'s day displayed' do
      before { click_link_or_button('23 October 2019') }

      scenario 'user can see Next page navigation only' do
        expect(page).to have_no_link('Previous')
        expect(page).to have_link('Next')
      end
    end

    context 'with a "middle" hearing\'s day displayed' do
      before { click_link_or_button('26 October 2019') }

      scenario 'user can see Next page and Previous navigation' do
        expect(page).to have_link('Previous')
        expect(page).to have_link('Next')
      end
    end

    context 'with a last hearing\'s day displayed' do
      before do
        click_link_or_button('31 October 2019')
        # There are 3 sitting days for this hearing
        click_link_or_button('Next')
        click_link_or_button('Next')
      end

      scenario 'user can see Previous page navigation only' do
        expect(page).to have_link('Previous')
        expect(page).to have_no_link('Next')
      end
    end
  end

  context 'when navigating between hearing days' do
    context 'when on first page' do
      before { click_link_or_button('23 October 2019') }

      scenario 'user can navigate to next hearing day' do
        click_link_or_button 'Next'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '26 October 2019')

        click_link_or_button 'Next'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '27 October 2019')
      end
    end

    context 'when on last page' do
      before { click_link_or_button('31 October 2019') }

      scenario 'user can navigate to previous hearing days' do
        click_link_or_button 'Previous'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '28 October 2019')

        click_link_or_button 'Previous'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '27 October 2019')
      end
    end
  end
end
