# frozen_string_literal: true

RSpec.describe User, type: :model do
  let(:user) do
    described_class.new(
      email: 'john.smith@example.com',
      first_name: 'John',
      last_name: 'Smith'
    )
  end

  # only attributes/methods that are additional to devise user
  it { is_expected.to respond_to(:first_name, :last_name, :name) }

  describe '#name' do
    subject { user.name }

    it 'returns "lastname, firstname"' do
      is_expected.to eql 'Smith, John'
    end
  end
end
