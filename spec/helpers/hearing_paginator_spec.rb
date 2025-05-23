# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.shared_context 'with single hearing and hearing day' do
  let(:hearings) { [hearing] }
  let(:hearing) do
    build(:hearing_summary, id: 'hearing-uuid-1',
                            hearing_days: [build(:hearing_day, sitting_day: '2021-01-20T10:00:00.000Z')])
  end
end

RSpec.shared_context 'with multiple hearings and hearing days' do
  let(:hearings) { [hearing1, hearing2, hearing3] }

  let(:hearing1) do
    build(:hearing_summary, id: 'hearing-uuid-1', hearing_days: hearing1_days)
  end

  let(:hearing2) do
    build(:hearing_summary, id: 'hearing-uuid-2', hearing_days: hearing2_days)
  end

  let(:hearing3) do
    build(:hearing_summary, id: 'hearing-uuid-3', hearing_days: hearing3_days)
  end

  let(:hearing1_days) { ['2021-01-19T10:45:00.000Z', '2021-01-20T10:45:00.000Z'] }
  let(:hearing2_days) { ['2021-01-20T10:00:00.000Z'] }
  let(:hearing3_days) { ['2021-01-18T11:00:00.000Z'] }

  let(:fake_hearings) do
    [
      build(:hearing_summary, id: 'hearing-uuid-3', day: hearing3_days.first.to_datetime),
      build(:hearing_summary, id: 'hearing-uuid-1', day: hearing1_days.first.to_datetime),
      build(:hearing_summary, id: 'hearing-uuid-1', day: hearing1_days.last.to_datetime),
      build(:hearing_summary, id: 'hearing-uuid-2', day: hearing2_days.first.to_datetime)
    ]
  end
end

RSpec.describe HearingPaginator, type: :helper do
  subject(:instance) { described_class.new(prosecution_case_decorator) }

  let(:prosecution_case_decorator) { Cda::CaseSummaryDecorator.new(prosecution_case, view_object) }

  let(:prosecution_case) do
    Cda::ProsecutionCase.new(hearing_summaries: hearings, prosecution_case_reference: 'ACASEURN')
  end

  let(:hearings) { [] }
  let(:view_object) { view_class.new }
  let(:view_class) do
    Class.new do
      include ApplicationHelper

      def t(*)
        nil
      end
    end
  end

  describe described_class::PageItem do
    it { is_expected.to respond_to(:id, :hearing_date) }
  end

  describe '#current_page' do
    subject(:current_page) { instance.current_page }

    context 'when current page is set' do
      let(:instance) { described_class.new(prosecution_case_decorator, page: 3) }

      it { is_expected.to be 3 }
    end

    context 'when current page is not set' do
      let(:instance) { described_class.new(prosecution_case_decorator) }

      it { is_expected.to be 0 }
    end
  end

  describe '#items' do
    subject(:items) { instance.items }

    context 'with multiple hearings' do
      include_context 'with multiple hearings and hearing days'

      let(:expected_result) do
        [described_class::PageItem.new('hearing-uuid-3', '2021-01-18T11:00:00.000Z'.to_datetime),
         described_class::PageItem.new('hearing-uuid-1', '2021-01-19T10:45:00.000Z'.to_datetime),
         described_class::PageItem.new('hearing-uuid-1', '2021-01-20T10:45:00.000Z'.to_datetime),
         described_class::PageItem.new('hearing-uuid-2', '2021-01-20T10:00:00.000Z'.to_datetime)]
      end

      before do
        allow(prosecution_case_decorator).to receive(:sorted_hearing_summaries_with_day).and_return(
          fake_hearings
        )
      end

      it { is_expected.to be_an(Array).and all(be_an(described_class::PageItem)) }

      it 'each item has an id' do
        ids = items.map(&:id)
        expect(ids).to match_array(%w[hearing-uuid-1 hearing-uuid-1 hearing-uuid-2 hearing-uuid-3])
      end

      it 'each item has a hearing datetime' do
        dates = items.map(&:hearing_date)
        expect(dates).to all(be_a(DateTime))
      end

      it 'array of items is sorted by hearing and then datetime' do
        is_expected.to eql(expected_result)
      end
    end
  end

  describe '#current_item' do
    subject(:current_item) { instance.current_item }

    include_context 'with multiple hearings and hearing days'

    before do
      allow(prosecution_case_decorator).to receive(:sorted_hearing_summaries_with_day).and_return(
        fake_hearings
      )
    end

    context 'when current_page set' do
      let(:instance) { described_class.new(prosecution_case_decorator, page: 3) }

      it { is_expected.to be_instance_of(described_class::PageItem) }
      it { is_expected.to have_attributes(id: hearing2.id) }
    end

    context 'when current_page not set' do
      let(:instance) { described_class.new(prosecution_case_decorator, page: nil) }

      it { is_expected.to be_instance_of(described_class::PageItem) }
      it { is_expected.to have_attributes(id: hearing3.id) }
    end
  end

  describe '#first_page' do
    subject { instance.first_page }

    it { is_expected.to be(0) }
  end

  describe '#first_page?' do
    subject { instance.first_page? }

    context 'with single hearing and hearing day' do
      include_context 'with single hearing and hearing day'

      context 'when current page is first page' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: 0) }

        it { is_expected.to be_truthy }
      end

      context 'when current page is nil' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: nil) }

        it { is_expected.to be_truthy }
      end

      context 'when current page is not first page' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: 1) }

        it { is_expected.to be_falsey }
      end
    end

    context 'with multiple hearings and hearing days' do
      include_context 'with multiple hearings and hearing days'

      context 'when current page is first page' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: 0) }

        it { is_expected.to be_truthy }
      end

      context 'when current page is nil' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: nil) }

        it { is_expected.to be_truthy }
      end

      context 'when current page is last page' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: 3) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#last_page' do
    subject { instance.last_page }

    context 'with no hearings' do
      let(:hearings) { [] }

      it { is_expected.to be(0) }
    end

    context 'with single hearing and hearing day' do
      include_context 'with single hearing and hearing day'

      it { is_expected.to be(0) }
    end

    context 'with multiple hearings and hearing days' do
      include_context 'with multiple hearings and hearing days'

      before do
        allow(prosecution_case_decorator).to receive(:sorted_hearing_summaries_with_day).and_return(
          fake_hearings
        )
      end

      it { is_expected.to be(3) }
    end
  end

  describe '#last_page?' do
    subject { instance.last_page? }

    context 'with single hearing and hearing day' do
      include_context 'with single hearing and hearing day'

      context 'when current page is last page' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: 0) }

        it { is_expected.to be_truthy }
      end

      context 'when current page is nil' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: nil) }

        it { is_expected.to be_truthy }
      end
    end

    context 'with multiple hearings and hearing days' do
      include_context 'with multiple hearings and hearing days'

      before do
        allow(prosecution_case_decorator).to receive(:sorted_hearing_summaries_with_day).and_return(
          fake_hearings
        )
      end

      context 'when current page is first page' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: 0) }

        it { is_expected.to be_falsey }
      end

      context 'when current page is nil' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: nil) }

        it { is_expected.to be_falsey }
      end

      context 'when current page is last page' do
        let(:instance) { described_class.new(prosecution_case_decorator, page: 3) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#next_page_link' do
    subject { instance.next_page_link }

    include_context 'with multiple hearings and hearing days'

    let(:instance) { described_class.new(prosecution_case_decorator, page: 0) }

    before do
      allow(prosecution_case_decorator).to receive(:sorted_hearing_summaries_with_day).and_return(
        fake_hearings
      )
    end

    it { is_expected.to have_link('Next') }

    it {
      is_expected.to have_link('Next',
                               href: %r{/hearings/#{hearing1.id}\?
                               column=date&direction=asc&page=1&urn=ACASEURN}x)
    }

    it {
      is_expected.to have_link('Next',
                               class: 'moj-pagination__link')
    }
  end

  describe '#previous_page_link' do
    subject { instance.previous_page_link }

    include_context 'with multiple hearings and hearing days'

    let(:instance) { described_class.new(prosecution_case_decorator, page: 3) }

    before do
      allow(prosecution_case_decorator).to receive(:sorted_hearing_summaries_with_day).and_return(
        fake_hearings
      )
    end

    it { is_expected.to have_link('Previous') }

    it {
      is_expected.to have_link('Previous',
                               href: %r{/hearings/#{hearing1.id}\?
                               column=date&direction=asc&page=2&urn=ACASEURN}x)
    }

    it {
      is_expected.to have_link('Previous',
                               class: 'moj-pagination__link')
    }
  end
end
