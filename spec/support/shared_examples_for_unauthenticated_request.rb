# frozen_string_literal: true

RSpec.shared_examples 'unauthenticated request' do
  it 'redirects to sign in page' do
    expect(response).to redirect_to new_user_session_path
  end

  it 'flashes alert' do
    expect(flash.now[:alert]).to match(/sign in before continuing/)
  end
end
