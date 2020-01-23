# frozen_string_literal: true

RSpec.describe User, type: :model do
  let(:user) do
    build(:user,
          email: 'john.smith@example.com',
          first_name: 'John',
          last_name: 'Smith')
  end

  # only attributes/methods that are additional to devise user
  it { is_expected.to respond_to(:first_name, :last_name, :name, :roles) }

  describe '#name' do
    subject { user.name }

    it 'returns "firstname lastname"' do
      is_expected.to eql 'John Smith'
    end
  end

  describe 'roles' do
    describe '.valid_roles' do
      subject { described_class.valid_roles }

      it 'returns all valid roles for class' do
        is_expected.to eq %w[caseworker manager admin]
      end
    end

    describe '#roles' do
      subject { user.roles }

      let(:user) { build(:user, roles: %i[caseworker manager]) }

      it 'returns roles on user object' do
        is_expected.to eq %w[caseworker manager]
      end
    end
  end
end
