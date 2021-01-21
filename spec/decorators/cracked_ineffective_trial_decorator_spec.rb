# frozen_string_literal: true

RSpec.describe CrackedIneffectiveTrialDecorator, type: :decorator do
  subject(:decorator) { described_class.new(cracked_ineffective_trial, view_object) }

  include RSpecHtmlMatchers

  let(:cracked_ineffective_trial) { instance_double(CourtDataAdaptor::Resource::CrackedIneffectiveTrial) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { cracked_ineffective_trial }
  end

  context 'when method is missing' do
    before { allow(cracked_ineffective_trial).to receive_messages(type: nil, code: nil) }

    it { is_expected.to respond_to(:type, :code) }
  end

  describe '#cracked?' do
    subject(:call) { decorator.cracked? }

    before do
      allow(cracked_ineffective_trial).to receive_messages(type: type, code: code)
    end

    context 'when type is cracked' do
      let(:type) { 'Cracked' }
      let(:code) { 'B' }

      it { is_expected.to be_truthy }
    end

    context 'when type is vacated with code indicating the trial cracked' do
      let(:type) { 'Vacated' }

      def self.vacated_cracked_trial_test_codes
        %w[A L M N O Q]
      end

      vacated_cracked_trial_test_codes.each do |code|
        context "with code #{code}" do
          let(:code) { code }

          it { is_expected.to be_truthy }
        end
      end
    end

    context 'when type is vacated with code indicating it is NOT a cracked trial' do
      let(:type) { 'Vacated' }
      let(:code) { 'P' }

      it { is_expected.to be_falsey }
    end

    context 'when type is ineffective' do
      let(:type) { 'Ineffective' } # CP/adaptor returns initicap'ed text
      let(:code) { 'A' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#type_sentence' do
    subject(:call) { decorator.type_sentence(link) }

    let(:link) { '<a href="/my/path">my link</a>'.html_safe }

    before do
      allow(cracked_ineffective_trial).to receive_messages(type: type)
    end

    context 'when type is cracked' do
      let(:type) { 'CrACKed' }

      it { is_expected.to include('Cracked on') }
      it { is_expected.to have_tag('a', text: 'my link') }
    end

    context 'when type is vacated' do
      let(:type) { 'Vacated' }

      it { is_expected.to include('Vacated on') }
      it { is_expected.to have_tag('a', text: 'my link') }
    end
  end

  describe '#description_sentence' do
    subject(:call) { decorator.description_sentence }

    before do
      allow(cracked_ineffective_trial)
        .to receive_messages(type: 'IneFFectiVE',
                             description: 'Another case over-ran')
    end

    it { is_expected.to eql('Ineffective: Another case over-ran') }
  end
end
