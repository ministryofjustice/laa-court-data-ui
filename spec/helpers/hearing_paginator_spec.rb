# frozen_string_literal: true

require 'court_data_adaptor'

# RSpec.shared_context 'with single hearing and hearing day' do
#   let(:hearings) { [hearing] }
#   let(:hearing) do
#     CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-1', hearing_days: ['2021-01-20T10:00:00.000Z'])
#   end
# end

RSpec.shared_context 'with multiple hearings and hearing days' do
  # let(:hearings) { [hearing1, hearing2, hearing3] }

  # let(:hearing1) do
  #   CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-1', hearing_days: hearing1_days)
  # end

  # let(:hearing2) do
  #   CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-2', hearing_days: hearing2_days)
  # end

  # let(:hearing3) do
  #   CourtDataAdaptor::Resource::Hearing.new(id: 'hearing-uuid-3', hearing_days: hearing3_days)
  # end

  # let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
  # let(:hearing2_days) { ['2021-01-20T10:00:00.000Z'] }
  # let(:hearing3_days) { ['2021-01-18T11:00:00.000Z'] }
end

RSpec.describe HearingPaginator, type: :helper do
  subject(:instance) { described_class.new(case_summary_decorator) }

  let(:case_summary_decorator) { CdApi::CaseSummaryDecorator.new(case_summary, view_object) }

  let(:case_summary) do
    cs = build(:case_summary)

    cs.hearing_summaries = [
      build(:hearing_summary, id: 'hearing-uuid-1', hearing_days: [
              build(:hearing_day, sitting_day: DateTime.parse('2021-01-19T00:00:00.000Z'))
            ]),
      build(:hearing_summary, id: 'hearing-uuid-2', hearing_days: [
              build(:hearing_day, sitting_day: DateTime.parse('2021-01-20T00:00:00.000Z'))
            ]),
      build(:hearing_summary, id: 'hearing-uuid-3', hearing_days: [
              build(:hearing_day, sitting_day: DateTime.parse('2021-01-18T00:00:00.000Z'))
            ])
    ]
    cs
  end

  let(:hearings) { [] }
  let(:view_object) { view_class.new }
  let(:view_class) { Class.new { include ApplicationHelper } }

  describe described_class::PageItem do
    it { is_expected.to respond_to(:id, :hearing_date) }
  end

  describe '#current_page' do
    subject(:current_page) { instance.current_page }

    context 'when current page is set' do
      let(:instance) { described_class.new(case_summary_decorator, page: 3) }

      it { is_expected.to be 3 }
    end

    context 'when current page is not set' do
      let(:instance) { described_class.new(case_summary_decorator) }

      it { is_expected.to be 0 }
    end
  end

  describe '#next_page_link' do
    subject { instance.next_page_link }

    let(:instance) { described_class.new(case_summary_decorator, page: 0) }

    it { is_expected.to have_link('Next') }

    it {
      hearing_id = 'hearing-uuid-1'
      url_params = 'column=date&direction=asc&page=1'

      is_expected.to have_link('Next',
                               href: %r{/hearings/#{hearing_id}\?#{url_params}&urn=THECASEURN})
    }

    it { is_expected.to have_link('Next', class: 'moj-pagination__link') }
  end

  describe '#previous_page_link' do
    subject { instance.previous_page_link }

    let(:instance) { described_class.new(case_summary_decorator, page: 3) }

    it { is_expected.to have_link('Previous') }

    it {
      hearing_id = 'hearing-uuid-2'
      url_params = 'column=date&direction=asc&page=2'

      is_expected.to have_link('Previous',
                               href: %r{/hearings/#{hearing_id}\?#{url_params}&urn=THECASEURN}x)
    }

    it { is_expected.to have_link('Previous', class: 'moj-pagination__link') }
  end

  describe '#items' do
    subject(:items) { instance.items }

    context 'with multiple hearings' do
      include_context 'with multiple hearings and hearing days'

      let(:expected_result) do
        [described_class::PageItem.new('hearing-uuid-3', '2021-01-18T00:00:00.000Z'.to_datetime),
         described_class::PageItem.new('hearing-uuid-1', '2021-01-19T00:00:00.000Z'.to_datetime),
         described_class::PageItem.new('hearing-uuid-2', '2021-01-20T00:00:00.000Z'.to_datetime)]
      end

      it { is_expected.to be_an(Array).and all(be_an(described_class::PageItem)) }

      it 'each item has an id' do
        ids = items.map(&:id)
        expect(ids).to match_array(%w[hearing-uuid-1 hearing-uuid-2 hearing-uuid-3])
      end

      it 'each item has a hearing datetime' do
        dates = items.map(&:hearing_date)
        expect(dates).to all(be_a(DateTime))
      end

      it 'array of items is sorted by hearing and then datetime' do
        is_expected.to eql(expected_result)
      end

      describe '#first_page' do
        subject { instance.first_page }

        it { is_expected.to be(0) }
      end

      describe '#last_page' do
        subject { instance.last_page }

        it { is_expected.to be(expected_result.count - 1) }
      end
    end

    context 'when the hearings table sort is "date desc"' do
      let(:expected_result) do
        [described_class::PageItem.new('hearing-uuid-2', '2021-01-20T00:00:00.000Z'.to_datetime),
         described_class::PageItem.new('hearing-uuid-1', '2021-01-19T00:00:00.000Z'.to_datetime),
         described_class::PageItem.new('hearing-uuid-3', '2021-01-18T00:00:00.000Z'.to_datetime)]
      end

      before do
        allow(case_summary_decorator).to receive_messages(hearings_sort_column: 'date',
                                                          hearings_sort_direction: 'desc')
      end

      it 'array of items is sorted by date desc' do
        is_expected.to eql(expected_result)
      end
    end
  end

  describe '#current_item' do
    subject(:current_item) { instance.current_item }

    context 'when current_page set' do
      let(:instance) { described_class.new(case_summary_decorator, page: 2) }

      it { is_expected.to be_instance_of(described_class::PageItem) }
      it { is_expected.to have_attributes(id: 'hearing-uuid-2') }
    end

    context 'when current_page not set' do
      let(:instance) { described_class.new(case_summary_decorator, page: nil) }

      it { is_expected.to be_instance_of(described_class::PageItem) }
      it { is_expected.to have_attributes(id: 'hearing-uuid-3') }
    end
  end

  describe '#first_page?' do
    subject { instance.first_page? }

    context 'when current page is first page' do
      let(:instance) { described_class.new(case_summary_decorator, page: 0) }

      it { is_expected.to be_truthy }
    end

    context 'when current page is nil' do
      let(:instance) { described_class.new(case_summary_decorator, page: nil) }

      it { is_expected.to be_truthy }
    end

    context 'when current page is last page' do
      let(:instance) { described_class.new(case_summary_decorator, page: 3) }

      it { is_expected.to be_falsey }
    end
  end
end
