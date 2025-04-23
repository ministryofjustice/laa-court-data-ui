# frozen_string_literal: true

RSpec.describe 'hearings/_hearing_events.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'hearing_events', locals: { hearing: decorated_hearing, hearing_day: }
  end

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }
  let(:decorated_hearing) { view.decorate(hearing) }
  let(:hearing_day) { Date.parse('2021-01-17T10:30:00.000Z') }

  let(:hearing_event1) do
    hearing_event_class.new(description: 'day 1 start', note: '1 hour delay',
                            occurred_at: '2021-01-17T10:30:00.000Z')
  end

  let(:hearing_event2) do
    hearing_event_class.new(description: 'day 1 end', note: 'ended late',
                            occurred_at: '2021-01-17T16:30:00.000Z')
  end

  let(:hearing_event3) do
    hearing_event_class.new(description: 'day 2 start', note: '2 hour delay',
                            occurred_at: '2021-01-18T10:45:00.000Z')
  end

  let(:hearing_event_class) { CourtDataAdaptor::Resource::HearingEvent }

  before do
    allow(hearing).to receive(:hearing_events).and_return(hearing_events)
  end

  context 'without hearing_events' do
    let(:hearing_events) { [] }

    it 'renders template without error' do
      is_expected.to render_template(:_hearing_events)
    end
  end

  context 'with hearing_events' do
    let(:hearing_events) { [hearing_event3, hearing_event1, hearing_event2] }

    it 'displays hearing event row columns' do
      is_expected
        .to have_css('thead th', text: 'Time')
        .and have_css('thead th', text: 'Event')
    end

    it 'filters hearing events for that day' do
      is_expected.to have_css('td.govuk-table__cell', text: 'day 1', count: 2)
    end

    it 'filters outs hearing events from other days' do
      is_expected.to have_no_css('td.govuk-table__cell', text: 'day 2')
    end

    it 'sorts hearing events earliest to latest' do
      is_expected
        .to have_css('tbody.govuk-table__body tr:nth-child(1)', text: '10:30')
        .and have_css('tbody.govuk-table__body tr:nth-child(2)', text: '16:30')
    end

    context 'with hearing_events notes' do
      it 'displays the notes' do
        is_expected
          .to have_content('1 hour delay')
          .and have_content('ended late')
      end

      context 'with notes containing html, unicode and crlf_escape_sequences' do
        let(:hearing_event_with_special_characters) do
          hearing_event_class.new(description: 'day 1 start', note: free_text,
                                  occurred_at: '2021-01-17T10:30:00.000Z')
        end
        let(:hearing_events) { [hearing_event_with_special_characters] }

        it_behaves_like 'free text fields'
      end
    end

    context 'with no hearing_events notes' do
      let(:hearing_event_with_empty_notes) do
        hearing_event_class.new(description: '1 hour delay', note: nil,
                                occurred_at: '2021-01-17T10:30:00.000Z')
      end
      let(:hearing_events) { [hearing_event_with_empty_notes] }

      it 'displays only the description' do
        is_expected.to have_content('1 hour delay')
      end
    end
  end
end
