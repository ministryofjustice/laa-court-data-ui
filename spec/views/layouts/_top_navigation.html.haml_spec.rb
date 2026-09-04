# frozen_string_literal: true

RSpec.describe "layouts/_top_navigation.html.haml", type: :view do
  subject(:render_partial) { render }

  let(:current_user) { instance_double(User, name: "Jane Doe") }

  before do
    allow(view).to receive(:user_path).with(current_user).and_return("/users/123")
    allow(view).to receive_messages(
      signed_in?: signed_in,
      current_user: current_user,
      destroy_user_session_path: "/users/sign_out",
      unauthenticated_root_path: "/",
    )
  end

  context "when signed in" do
    let(:signed_in) { true }

    it "renders account and sign out links" do
      render

      expect(rendered).to have_css('nav[aria-label="Account navigation"]')
      expect(rendered).to have_link("Jane Doe - edit user details", href: "/users/123")
      expect(rendered).to have_link("Sign out", href: "/users/sign_out")
    end
  end

  context "when signed out" do
    let(:signed_in) { false }

    it "renders sign in link only" do
      render

      expect(rendered).to have_css('nav[aria-label="Account navigation"]')
      expect(rendered).to have_link("Sign in", href: "/")
      expect(rendered).to have_no_link("Sign out")
      expect(rendered).to have_no_link("Jane Doe - edit user details")
    end
  end
end
