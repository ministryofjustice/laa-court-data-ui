# frozen_string_literal: true

RSpec.describe 'hearings/_hearing_events.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'hearing_events', locals: { hearing_events:, hearing_day: }
  end

  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_events) do
    CdApi::HearingEvents.find(hearing_id,
                              { date: hearing_day.strftime('%F') })
  end

  context 'without hearing_events', :stub_v2_hearing_events_empty do
    it 'renders template without error' do
      is_expected.to render_template(:_hearing_events)
    end
  end

  context 'with hearing events', :stub_v2_hearing_events do
    it 'displays hearing event row columns' do
      is_expected
        .to have_css('thead th', text: 'Time')
        .and have_css('thead th', text: 'Event')
    end

    context 'with hearing_events notes' do
      it 'displays the notes' do
        is_expected
          .to have_content('Hearing event 0')
          .and have_content('Hearing note 0')
      end
    end

    context 'with no hearing_events notes' do
      it 'displays the row' do
        is_expected
          .to have_content('Hearing event 1')
      end
    end

    context 'with notes containing html, unicode and crlf_escape_sequences' do
      it 'renders unicode characters correctly' do
        is_expected.to have_content('!\"#£%&()*,-./Æ½ŵ€')
      end

      it 'does not render unpermitted html' do
        is_expected.to have_content('a comment and (this is another example)')
      end

      it 'renders crlf escape sequences correctly' do
        is_expected.to have_content("text\nmore details\nother information\n")
      end
    end
  end
end
