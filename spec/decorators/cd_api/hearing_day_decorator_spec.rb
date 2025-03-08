# frozen_string_literal: true

RSpec.describe CdApi::HearingDayDecorator, type: :decorator do
  subject(:decorator) { described_class.new(hearing_day, view_object) }

  let(:hearing_day) { build(:hearing_day) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  before do
    allow(FeatureFlag).to receive(:enabled?).with(:hearing_summaries).and_return(true)
  end

  it_behaves_like 'a base decorator' do
    let(:object) { hearing_day }
  end

  describe '#to_datetime' do
    subject(:call) { decorator.to_datetime }

    context 'when there are sitting days' do
      let(:hearing_day) { build(:hearing_day, sitting_day:) }
      let(:sitting_day) { '2021-01-19T10:45:00.000Z' }

      it 'returns sitting day in datetime type' do
        expect(call).to be_instance_of(DateTime)
      end

      it 'returns sitting day' do
        expect(call).to eq sitting_day
      end
    end

    context 'when there are no sitting days' do
      let(:hearing_day) { build(:hearing_day, sitting_day: nil) }

      it 'returns nil' do
        expect(call).to be_nil
      end
    end
  end
end
