# frozen_string_literal: true

RSpec.describe Roles, type: :concern do
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations
      include Roles

      accepts_roles :terminator, :stormtrooper
      attr_accessor :roles

      def initialize(options = {})
        @roles = options[:roles]
        super
      end
    end
  end

  before do
    test_class.accepts_roles(:terminator, :stormtrooper)
  end

  describe '.accepts_roles' do
    before { test_class.accepts_roles(:replicant, :marvin) }

    it 'defines valid roles for class' do
      expect(test_class.valid_roles).to match_array(%w[replicant marvin])
    end
  end

  describe '.valid_roles' do
    it { expect(test_class.valid_roles).to match_array(%w[terminator stormtrooper]) }
  end

  describe '#validate_role_presence' do
    let(:object) { test_class.new }

    context 'when role not present' do
      it 'renders object invalid' do
        expect(object).not_to be_valid
      end

      it 'adds error to object' do
        object.valid?
        expect(object.errors[:roles]).to include('must have a role')
      end
    end
  end

  describe '#validate_role_inclusion' do
    let(:object) { test_class.new(roles: %i[jedi sith]) }

    context 'when role not one of those allowed' do
      it 'renders object invalid' do
        expect(object).not_to be_valid
      end

      it 'adds error to object' do
        object.valid?
        expect(object.errors[:roles]).to include('jedi is not a valid role')
      end
    end
  end

  describe '#roles' do
    let(:object) { test_class.new(roles: ['stormtrooper']) }

    it { expect(object.roles).to contain_exactly('stormtrooper') }
  end

  # rubocop:disable RSpec/PredicateMatcher
  describe '#"role"?' do
    let(:object) { test_class.new(roles: ['terminator']) }

    context 'when "role" exists and object has it' do
      it { expect(object.terminator?).to be_truthy }
    end

    context 'when "role" exists but object does not have it' do
      it { expect(object.stormtrooper?).to be_falsey }
    end

    context 'when "role" does not exist' do
      it { expect { object.replicant? }.to raise_error NoMethodError }
    end
  end

  describe '#responds_to?(:"role"?)' do
    let(:object) { test_class.new(roles: ['terminator']) }

    context 'when "role" exists' do
      it { expect(object.respond_to?(:stormtrooper?)).to be_truthy }
    end

    context 'when "role" does not exist' do
      it { expect(object.respond_to?(:replicant?)).to be_falsey }
    end
  end
  # rubocop:enable RSpec/PredicateMatcher
end
