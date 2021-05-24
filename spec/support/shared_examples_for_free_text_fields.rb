# frozen_string_literal: true

RSpec.shared_context 'with free text fields' do
  let(:free_text_with_unicode_notes) { '!\"#£%&()*,-./Æ½ŵ€' }

  let(:free_text_with_unpermitted_html) { '<b>a comment</b> <script>and (this is another example)</script>' }

  let(:free_text_with_crlf_escape_sequences) do
    "\ntext\r\nmore details\rother information"
  end
end

RSpec.shared_examples 'free text fields' do
  include_context 'with free text fields'

  let(:free_text) { '' }
  context 'with text containing unicode characters' do
    let(:free_text) { free_text_with_unicode_notes }

    it 'renders unicode characters correctly' do
      is_expected.to have_content('!\"#£%&()*,-./Æ½ŵ€')
    end
  end

  context 'with text with unpermitted html' do
    let(:free_text) { free_text_with_unpermitted_html }

    it 'does not render unpermitted htl' do
      is_expected.to have_content('a comment and (this is another example)')
    end
  end

  context 'with text containing crlf escape sequences' do
    let(:free_text) { free_text_with_crlf_escape_sequences }

    it 'renders crlf escape sequences correctly' do
      is_expected.to have_content("text\nmore details\nother information\n")
    end
  end
end
