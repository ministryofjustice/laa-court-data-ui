# frozen_string_literal: true

RSpec.describe 'hearings/_court_applications.html.haml', type: :view do
  subject(:render_partial) { render partial: 'court_applications', locals: { hearing: decorated_hearing } }

  include RSpecHtmlMatchers

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }
  let(:decorated_hearing) { view.decorate(hearing) }

  it { is_expected.to have_selector('.govuk-heading-m', text: 'Applications') }
end
