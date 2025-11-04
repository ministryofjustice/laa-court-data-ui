# frozen_string_literal: true

RSpec.shared_examples 'renders search validation errors' do
  it { expect(response.body).to include('searches/new') }
  it { expect(response.body).to include('searches/_form') }
  it { expect(response.body).not_to include('searches/_results') }
  it { expect(response.body).to include('There is a problem') }
end

RSpec.shared_examples 'renders results' do
  it { expect(response.body).to include('searches/new') }
  it { expect(response.body).to include('searches/_form') }
  it { expect(response.body).to include('searches/_results') }
  it { expect(response.body).to include('searches/_results_header') }
end
