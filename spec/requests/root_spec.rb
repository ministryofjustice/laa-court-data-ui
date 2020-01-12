# frozen_string_literal: true

RSpec.describe 'Root route', type: :request do
  before { get '/' }

  it 'renders search_filters/new' do
    expect(response).to render_template('search_filters/new')
  end
end
