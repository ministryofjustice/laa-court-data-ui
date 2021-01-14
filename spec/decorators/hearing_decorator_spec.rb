# frozen_string_literal: true

RSpec.describe HearingDecorator, type: :decorator do
  subject(:decorator) { described_class.new(hearing, view_object) }

  let(:hearing) { instance_double(CourtDataAdaptor::Resource::Hearing) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { hearing }
  end

  context 'when method is missing' do
    before { allow(hearing).to receive_messages(providers: nil) }

    it { is_expected.to respond_to(:providers) }
  end

  describe '#provider_list' do
    subject(:call) { decorator.provider_list }

    before { allow(hearing).to receive_messages(providers: providers) }

    context 'with multiple providers' do
      let(:providers) { [provider1, provider2] }
      let(:provider1) { CourtDataAdaptor::Resource::Provider.new(name: 'Jammy Dodger', role: 'Junior') }
      let(:provider2) { CourtDataAdaptor::Resource::Provider.new(name: 'Bob Smith', role: 'QC') }

      it { is_expected.to eql('Jammy Dodger (Junior)<br>Bob Smith (QC)') }
    end

    context 'with no providers' do
      let(:providers) { [] }

      it { is_expected.to eql 'Not available' }
    end

    context 'with missing provider details' do
      let(:providers) { [provider1, provider2] }
      let(:provider1) { CourtDataAdaptor::Resource::Provider.new(role: 'Junior') }
      let(:provider2) { CourtDataAdaptor::Resource::Provider.new(name: 'Bob Smith') }

      it { is_expected.to eql 'Not available (Junior)<br>Bob Smith (not available)' }
    end
  end

  describe '#defendant_name_list' do
    subject(:call) { decorator.defendant_name_list }

    before { allow(hearing).to receive_messages(defendant_names: defendant_names) }

    context 'with nil defendant_names' do
      let(:defendant_names) { nil }

      it { is_expected.to eql 'Not available' }
    end

    context 'with empty defendant_names' do
      let(:defendant_names) { [] }

      it { is_expected.to eql 'Not available' }
    end

    context 'with one defendant_names element' do
      let(:defendant_names) { ['Joe Bloggs'] }

      it { is_expected.to eql 'Joe Bloggs' }
    end

    context 'with multiple defendant_names element' do
      let(:defendant_names) { ['Joe Bloggs', 'Fred Dibnah'] }

      it { is_expected.to eql 'Joe Bloggs<br>Fred Dibnah' }
    end
  end

  describe '#prosecution_advocate_name_list' do
    subject(:call) { decorator.prosecution_advocate_name_list }

    before { allow(hearing).to receive_messages(prosecution_advocate_names: prosecution_advocate_names) }

    context 'with nil prosecution_advocate_names' do
      let(:prosecution_advocate_names) { nil }

      it { is_expected.to eql 'Not available' }
    end

    context 'with empty prosecution_advocate_names' do
      let(:prosecution_advocate_names) { [] }

      it { is_expected.to eql 'Not available' }
    end

    context 'with one prosecution_advocate_names element' do
      let(:prosecution_advocate_names) { ['Percy Prosecutor'] }

      it { is_expected.to eql 'Percy Prosecutor' }
    end

    context 'with multiple prosecution_advocate_names element' do
      let(:prosecution_advocate_names) { ['Percy Prosecutor', 'Linda Lawless'] }

      it { is_expected.to eql 'Percy Prosecutor<br>Linda Lawless' }
    end
  end

  describe '#judge_name_list' do
    subject(:call) { decorator.judge_name_list }

    before { allow(hearing).to receive_messages(judge_names: judge_names) }

    context 'with nil prosecution_advocate_names' do
      let(:judge_names) { nil }

      it { is_expected.to eql 'Not available' }
    end

    context 'with empty prosecution_advocate_names' do
      let(:judge_names) { [] }

      it { is_expected.to eql 'Not available' }
    end

    context 'with one prosecution_advocate_names element' do
      let(:judge_names) { ['Mr Justice Pomfrey'] }

      it { is_expected.to eql 'Mr Justice Pomfrey' }
    end

    context 'with multiple prosecution_advocate_names element' do
      let(:judge_names) { ['Mr Justice Pomfrey', 'Ms Justice Arden'] }

      it { is_expected.to eql 'Mr Justice Pomfrey<br>Ms Justice Arden' }
    end
  end

  describe '#cracked_ineffective_trial' do
    subject(:call) { decorator.cracked_ineffective_trial }

    before { allow(hearing).to receive_messages(cracked_ineffective_trial: cracked_ineffective_trial) }

    context 'with nil cracked_ineffective_trial' do
      let(:cracked_ineffective_trial) { nil }

      it { is_expected.to be_nil }
    end

    context 'with a cracked_ineffective_trial relation' do
      let(:cracked_ineffective_trial) { CourtDataAdaptor::Resource::CrackedIneffectiveTrial.new }

      it { is_expected.to be_instance_of(CrackedIneffectiveTrialDecorator) }
    end
  end
end
