# frozen_string_literal: true

RSpec.shared_examples 'renders search validation errors' do
  it { expect(response).to render_template('searches/new') }
  it { expect(response).to render_template('searches/_form') }
  it { expect(response).not_to render_template('searches/_results') }
  it { expect(response.body).to include('There is a problem') }
end

RSpec.shared_examples 'renders results' do
  it { expect(response).to render_template('searches/new') }
  it { expect(response).to render_template('searches/_form') }
  it { expect(response).to render_template('searches/_results') }
  it { expect(response).to render_template('searches/_results_header') }
end
