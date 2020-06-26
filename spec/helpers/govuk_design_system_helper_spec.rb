# frozen_string_literal: true

RSpec.describe GovukDesignSystemHelper, type: :helper do
  include RSpecHtmlMatchers

  describe '#govuk_page_title' do
    context 'when page title provided' do
      before do
        helper.govuk_page_title('My page title')
      end

      it 'stores :page_title' do
        expect(helper.content_for(:page_title)).to include 'My page title'
      end

      it 'stores :page_heading' do
        expect(helper.content_for(:page_heading)).to include 'My page title'
      end

      it ':page_title contains plain text' do
        expect(helper.content_for(:page_title)).to eql 'My page title - View court data - GOV.UK'
      end

      it ':page_heading contains GDS styled heading' do
        markup = helper.content_for(:page_heading)
        expect(markup).to eql '<h1 class="govuk-heading-xl">My page title</h1>'
      end
    end

    context 'when caption provided' do
      before do
        helper.govuk_page_title('My page title', 'My page caption')
      end

      it 'stores :page_title' do
        expect(helper.content_for(:page_title)).to include 'My page caption'
      end

      it 'stores :page_heading' do
        expect(helper.content_for(:page_heading)).to include 'My page caption'
      end

      it ':page_title contains caption in plain text' do
        expected_markup = 'My page caption My page title - View court data - GOV.UK'
        expect(helper.content_for(:page_title)).to eql expected_markup
      end

      it ':page_heading contains GDS styled heading caption' do
        markup = helper.content_for(:page_heading)
        expected_markup = '<h1 class="govuk-heading-xl">'\
                          '<span class="govuk-caption-xl">My page caption</span>'\
                          'My page title</h1>'
        expect(markup).to eql expected_markup
      end
    end

    context 'when no page title provided' do
      before do
        allow(controller).to receive(:controller_name).and_return 'Widgets'
        allow(controller).to receive(:action_name).and_return 'show'
        helper.govuk_page_title
      end

      it ':page_title contains title based on controller action' do
        expect(helper.content_for(:page_title)).to eql 'Show widget - View court data - GOV.UK'
      end

      it ':page_heading contains heading based on controller action' do
        markup = helper.content_for(:page_heading)
        expect(markup).to eql '<h1 class="govuk-heading-xl">Show widget</h1>'
      end
    end
  end

  describe '#govuk_detail' do
    subject(:markup) { helper.govuk_detail('My detail summary text') { 'My content' } }

    it 'adds detail with govuk class' do
      is_expected.to have_tag(:detail, with: { class: 'govuk-details' })
    end

    it 'adds detail without open attribute' do
      is_expected.not_to have_tag(:detail, with: { 'open': 'open' })
    end

    it 'adds detail govuk data-module' do
      is_expected.to have_tag(:detail, with: { 'data-module': 'govuk-details' })
    end

    it 'adds nested summary tag with govuk class' do
      is_expected.to have_tag(:detail) do
        with_tag(:summary, with: { class: 'govuk-details__summary' })
      end
    end

    it 'adds nested span in summary tag with govuk class' do
      is_expected.to have_tag(:detail) do
        with_tag(:summary) do
          with_tag(:span, with: { class: 'govuk-details__summary-text' })
        end
      end
    end

    it 'adds summary_text to nested span' do
      is_expected.to have_tag(:detail) do
        with_tag(:summary) do
          with_tag(:span, text: 'My detail summary text')
        end
      end
    end

    it 'adds nested div tag with govuk class' do
      is_expected.to have_tag(:detail) do
        with_tag(:div, with: { class: 'govuk-details__text' })
      end
    end

    it 'yields content to nested div tag' do
      is_expected.to have_tag(:detail) do
        with_tag(:div, with: { class: 'govuk-details__text' }) do
          with_text 'My content'
        end
      end
    end

    context 'with open true' do
      subject(:markup) { helper.govuk_detail('My detail summary text', true) { 'my content' } }

      it 'adds detail with open attribute' do
        is_expected.to have_tag(:detail, with: { 'open': 'open' })
      end
    end

    context 'with custom classes' do
      subject(:markup) do
        helper.govuk_detail('My detail summary text', false, class: 'my-custom-class1 my-custom-class2') do
          'my content'
        end
      end

      it 'adds detail with custom classes, prepended by govuk class' do
        is_expected.to have_tag(:detail, with: { class: 'govuk-details my-custom-class1 my-custom-class2' })
      end
    end
  end
end
