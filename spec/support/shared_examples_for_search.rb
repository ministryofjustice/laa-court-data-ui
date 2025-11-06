# frozen_string_literal: true

RSpec.shared_examples 'renders search validation errors' do
  
  it { expect(response.body).to include('There is a problem') }
end

RSpec.shared_examples 'renders results' do
  it { expect(response.body).to include('Search for') }

end
