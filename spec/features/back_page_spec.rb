# frozen_string_literal: true

RSpec.ffeature 'Back page', type: :feature do
  let(:user) { create(:user) }

  context 'when not signed in' do
    before { visit unauthenticated_root_path }

    it 'back page link not displayed' do
      expect(page).not_to have_link('Back')
    end
  end

  context 'when signed in' do
    before do
      sign_in user
    end

    context 'when on search filters page' do
      before { visit new_search_filter_path }

      scenario 'back page link is not displayed' do
        expect(page).not_to have_link('Back')
      end
    end

    context 'when on search page' do
      before { visit new_search_path(search: { filter: 'defendant' }) }

      scenario 'back page link is displayed' do
        expect(page).to have_link('Back')
      end
    end
  end
end
