# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root route', type: :request do
  before { get '/' }

  it 'renders search_filters/new' do
    expect(response).to render_template('search_filters/new')
  end
end
