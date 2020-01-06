# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Root route', :type => :request do
  before { get '/' }

  it 'renders search/new' do
    expect(response).to render_template('search/new')
  end
end
