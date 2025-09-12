require 'rails_helper'

RSpec.describe 'Maintenance mode', type: :feature do
  context 'when enabled' do
    before do
      allow(FeatureFlag).to receive(:enabled?).and_call_original
      allow(FeatureFlag).to receive(:enabled?).with(:out_of_hours).and_return(true)
      travel_to specified_time
      visit authenticated_root_path
    end

    context "when out of hours" do
      let(:specified_time) { DateTime.new(2025, 1, 1, 22, 0, 1) }

      it 'shows a relevant error' do
        expect(page).to have_content 'Sorry, this service is unavailable'
        expect(page).to have_content 'This service is available between 7am and 10pm each day.'
      end
    end

    context "when within hours" do
      let(:specified_time) { DateTime.new(2025, 1, 1, 7, 0, 1) }

      it 'does not block the page' do
        expect(page).to have_no_content 'Sorry, this service is unavailable'
      end
    end
  end
end
