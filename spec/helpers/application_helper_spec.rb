# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  subject { helper }

  it { is_expected.to respond_to :govuk_page_title }
  it { is_expected.to respond_to :govuk_breadcrumb_builder }
end
