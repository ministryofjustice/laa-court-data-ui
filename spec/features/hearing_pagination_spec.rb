# frozen_string_literal: true

RSpec.feature 'Hearing pagination', :vcr, type: :feature do
# RSpec.feature 'Hearing pagination', { cassette_name: 'hearing_pagination_cda', record: :new_episodes }, type: :feature do

  let(:user) { create(:user) }
  let(:case_urn) { 'IGWTRAXVHK' }
  let(:defendant_id) { '4bcf26f9-3c6f-440a-94aa-7d084bcd715' }
  # let(:hearing_id_from_fixture) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  before do
    dummy_token = instance_double('OAuth2::AccessToken', token: 'super-secret-key', expired?: false)
    allow(CourtDataAdaptor::OauthTokenProvider).to receive(:token).and_return(dummy_token)

    sign_in user
    visit "prosecution_cases/#{case_urn}"
  end

  def hearing_page_url(page_param)
    %r{hearings/.*\?column=date&direction=asc&page=#{page_param}&urn=IGWTRAXVHK}
  end

  context 'when viewing case details' do
    scenario 'user can see links to hearing pages' do
      within :table, 'Hearings' do
        expect(page).to have_link('01/05/2025', href: hearing_page_url(0), class: 'govuk-link')
        expect(page).to have_link('07/05/2025', href: hearing_page_url(1), class: 'govuk-link')
        expect(page).to have_link('08/05/2025', href: hearing_page_url(2), class: 'govuk-link')
      end
    end

    scenario 'user can navigate to a paginated hearing page' do
      click_link_or_button('01/05/2025')

      expect(page).to have_current_path(hearing_page_url(0), url: true)
    end
  end

  context 'when on hearing page' do
    context 'with first hearing\'s day displayed' do
      before { click_link_or_button('01/05/2025') }

      scenario 'user can see Next page navigation only' do
        expect(page).to have_no_link('Previous')
        expect(page).to have_link('Next')
      end
    end

    context 'with a "middle" hearing\'s day displayed' do
      before { click_link_or_button('07/05/2025') }

      scenario 'user can see Next page and Previous navigation' do
        expect(page).to have_link('Previous')
        expect(page).to have_link('Next')
      end
    end

    context 'with a last hearing\'s day displayed' do
      before { click_link_or_button('08/05/2025') }

      scenario 'user can see Previous page navigation only' do
        expect(page).to have_link('Previous')
        expect(page).to have_no_link('Next')
      end
    end
  end

  context 'when navigating between hearing days' do
    context 'when on first page' do
      before { click_link_or_button('01/05/2025') }

      scenario 'user can navigate to next hearing day' do
        click_link_or_button 'Next'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '07/05/2025')

        click_link_or_button 'Next'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '08/05/2025')
      end
    end

    context 'when on last page' do
      before { click_link_or_button('08/05/2025') }

      scenario 'user can navigate to previous hearing days' do
        click_link_or_button 'Previous'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '07/05/2025')

        click_link_or_button 'Previous'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '01/05/2025')
      end
    end
  end
end
