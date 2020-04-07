# frozen_string_literal: true

RSpec.describe GovukDesignSystemHelper, type: :helper do
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
end
