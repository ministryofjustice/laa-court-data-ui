require 'rails_helper'

RSpec.describe 'Maintenance mode', type: :feature do
  context 'when enabled' do
    before { allow(FeatureFlag).to receive(:enabled?).with(:maintenance_mode).and_return(true) }

    it 'shows a generic error' do
      visit authenticated_root_path
      expect(page).to have_content 'This service is currently unavailable'
    end
  end
end
