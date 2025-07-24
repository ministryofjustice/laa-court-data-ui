require 'rails_helper'

RSpec.describe 'Maintenance mode', type: :feature do
  context 'when enabled' do
    before do
      allow(FeatureFlag).to receive(:enabled?).with(:maintenance_mode).and_return(true)
      visit authenticated_root_path
    end

    it 'shows a generic error' do
      expect(page).to have_content 'This service is currently unavailable'
    end

    it 'is accessible', :js do
      expect(page).to be_accessible
    end
  end
end
