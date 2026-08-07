# frozen_string_literal: true

require 'gds_design_system_breadcrumb_builder'

RSpec.describe GdsDesignSystemBreadcrumbBuilder, type: :helper do
  subject(:builder) { described_class.new(helper, []) }

  it { is_expected.to respond_to :render, :render_element }

  describe '#render' do
    subject(:content) { builder.render }

    it 'renders outer <div>' do
      expect(content).to include(
        '<div class="govuk-breadcrumbs" role="navigation" aria-label="Navigate Case">'
      )
    end

    it 'renders order list <ol>' do
      expect(content).to include('<ol class="govuk-breadcrumbs__list">')
    end
  end
end
