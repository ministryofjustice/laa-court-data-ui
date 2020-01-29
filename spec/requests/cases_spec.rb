# frozen_string_literal: true

RSpec.describe 'cases', type: :request do
  let(:user) { create(:user, :with_caseworker_role) }
  let(:kase) { Case.new(id: Faker::Number.number(digits: 1)) }

  before do
    sign_in user
  end

  describe 'Show case', type: :request do
    it 'renders /cases/:id' do
      get case_path(kase.id)
      expect(response).to render_template('cases/show')
    end
  end
end
