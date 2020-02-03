# frozen_string_literal: true

RSpec.describe 'defendants', type: :request do
  let(:user) { create(:user, :with_caseworker_role) }
  let(:defendant) { Defendant.new(id: Faker::Number.number(digits: 1)) }

  before do
    sign_in user
  end

  describe 'Show defendant', type: :request do
    it 'renders /defendants/:id' do
      get defendant_path(defendant.id)
      expect(response).to render_template('defendants/show')
    end
  end
end
