# frozen_string_literal: true

RSpec.describe ProviderDecorator, type: :decorator do
  subject(:decorator) { described_class.new(provider, view_object) }

  let(:provider) { instance_double(CourtDataAdaptor::Resource::Provider) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { provider }
  end

  context 'when method is missing' do
    before { allow(provider).to receive_messages(name: nil, role: nil) }

    it { is_expected.to respond_to(:name, :role) }
  end

  describe '#name_and_role' do
    subject(:call) { decorator.name_and_role }

    context 'when name and role exist' do
      before { allow(provider).to receive_messages(name: 'Jammy Dodger', role: 'Junior') }

      it { is_expected.to eql('Jammy Dodger (Junior)') }
    end

    context 'when name blank' do
      before { allow(provider).to receive_messages(name: nil, role: 'Junior') }

      it { is_expected.to eql 'Not available (Junior)' }
    end

    context 'when role blank' do
      before { allow(provider).to receive_messages(name: 'Jammy Dodger', role: nil) }

      it { is_expected.to eql 'Jammy Dodger (not available)' }
    end

    context 'when name and role are blank' do
      before { allow(provider).to receive_messages(name: nil, role: nil) }

      it { is_expected.to eql 'Not available' }
    end
  end
end
