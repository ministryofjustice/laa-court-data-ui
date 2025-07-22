# frozen_string_literal: true

RSpec.describe HearingHelper, type: :helper do
  describe '#paginator' do
    subject(:call) { helper.paginator('prosecution_case', { page: '1' }) }

    let(:paginator_class) { class_double(HearingPaginator) }
    let(:paginator_instance) { instance_double(HearingPaginator) }

    before do
      stub_const(HearingPaginator.to_s, paginator_class)
      allow(paginator_class).to receive(:new).and_return(paginator_instance)
    end

    it { is_expected.to be paginator_instance }

    it {
      call
      expect(paginator_class).to have_received(:new).with('prosecution_case', { page: '1' })
    }
  end

  describe '#earliest_day_for' do
    subject { helper.earliest_day_for(hearing) }

    let(:hearing) do
      Cda::Hearing.new(
        hearing_days: ['2021-01-19T10:45:15.000Z',
                       '2021-01-19T10:45:30.000Z',
                       '2021-01-20T16:00:00.000Z']
      )
    end

    it { is_expected.to eql('2021-01-19T10:45:15.000Z'.to_datetime) }
  end

  describe '#transform_and_sanitize' do
    subject { helper.transform_and_sanitize(text) }

    context 'with notes containing unsafe and unpermitted html' do
      let(:text) { '<b>warning</b> <script>alert(123)</script>' }

      it { is_expected.to eq('warning alert(123)') }
    end

    context 'with notes containing crlf escape sequences' do
      let(:text) { "early start\nlate finish\r\ncase adjourned\rresume next week" }

      it { is_expected.to eq("early start\n<br>late finish\n<br>case adjourned\n<br>resume next week") }
    end

    context 'with plain text' do
      let(:text) { 'hearing begins' }

      it { is_expected.to eq('hearing begins') }
    end
  end
end
