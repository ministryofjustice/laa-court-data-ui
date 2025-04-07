# frozen_string_literal: true

RSpec.feature 'Hearing pagination', type: :feature do
  let(:user) { create(:user) }
  let(:case_urn) { '91GD2357322' }
  let(:defendant_id) { '40400f4b-4c02-4e7d-8f83-0d018a6b9642' }
  let(:hearing_id_from_fixture) { '345be88a-31cf-4a30-9de3-da98e973367e' }

  before do
    sign_in user
    VCR.insert_cassette('cdapi/hearing_pagination_spec')

    visit "prosecution_cases/#{case_urn}"
  end

  after do
    VCR.eject_cassette('hearing_pagination')
  end

  def hearing_page_url(page_param)
    %r{hearings/.*\?column=date&direction=asc&page=#{page_param}&urn=91GD2357322}
  end

  context 'when viewing case details' do
    scenario 'user can see links to hearing pages' do
      within :table, 'Hearings' do
        # First hearing date
        expect(page).to have_link('11/06/2022', href: hearing_page_url(0), class: 'govuk-link')

        # Forth hearing date
        expect(page).to have_link('11/07/2022', href: hearing_page_url(4), class: 'govuk-link')
      end
    end

    scenario 'user can navigate to a paginated hearing page' do
      click_link_or_button('11/06/2022')
      expect(page).to have_current_path(hearing_page_url(0), url: true)
    end
  end

  context 'when on hearing page' do
    context 'with first hearing\'s day displayed' do
      before { click_link_or_button('11/06/2022') }

      scenario 'user can see Next page navigation only' do
        expect(page).to have_no_link('Previous')
        expect(page).to have_link('Next')
      end
    end

    context 'with a "middle" hearing\'s day displayed' do
      before { click_link_or_button('20/06/2022') }

      scenario 'user can see Next page and Previous navigation' do
        expect(page).to have_link('Previous')
        expect(page).to have_link('Next')
      end
    end
  end

  context 'when navigating between hearing days' do
    context 'when on first page' do
      before { click_link_or_button('20/06/2022') }

      scenario 'user can navigate to next hearing day' do
        click_link_or_button 'Next'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '27/06/2022')
      end
    end

    context 'when on last page' do
      before { click_link_or_button('11/07/2022') }

      scenario 'user can see Previous page navigation only' do
        expect(page).to have_link('Previous')
        expect(page).to have_no_link('Next')
      end

      scenario 'user can navigate to previous hearing days' do
        click_link_or_button 'Previous'
        expect(page)
          .to have_css('h1', text: 'Hearing day')
          .and have_css('h1', text: '27/06/2022')
      end
    end
  end
end
