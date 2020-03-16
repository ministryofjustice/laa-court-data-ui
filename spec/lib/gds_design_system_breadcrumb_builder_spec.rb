# frozen_string_literal: true

require 'gds_design_system_breadcrumb_builder'

RSpec.describe GdsDesignSystemBreadcrumbBuilder do
  subject(:builder) { described_class.new(template, []) }

  let(:template) { Class.new(ActionView::TestCase) }

  it { is_expected.to respond_to :render, :render_element }

  describe '#render', skip: 'FIX: test template not responding to :content_tag' do
    subject(:content) { builder.render }

    it 'renders outer <div>' do
      expect(content).to include('<div class="govuk-breadcrumbs">')
    end

    it 'renders order list <ol>' do
      expect(content).to include('<ol class="govuk-breadcrumbs__list">')
    end
  end
end
