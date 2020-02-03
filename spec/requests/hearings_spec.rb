# frozen_string_literal: true

RSpec.describe 'hearings', type: :request do
  let(:user) { create(:user, :with_caseworker_role) }
  let(:hearing) { Hearing.new(id: Faker::Number.number(digits: 1)) }

  before do
    sign_in user
  end

  describe 'Show hearing', type: :request do
    it 'renders /hearings/:id' do
      get hearing_path(hearing.id)
      expect(response).to render_template('hearings/show')
    end
  end
end
