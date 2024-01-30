# frozen_string_literal: true

RSpec.describe CharLengthValidator, type: :validator do
  subject(:foo_instance) { foo_model.new(string_field: string_value) }

  let(:foo_model) do
    Class.new do
      include ActiveModel::Model

      def self.name
        'FooModel'
      end

      attr_accessor :string_field

      validates :string_field,
                char_length: { minimum: 3 }
    end
  end

  context 'with nil' do
    let(:string_value) { nil }

    it { is_expected.to be_valid }
  end

  context 'with exactly the minimum number of chars' do
    let(:string_value) { 'aaa' }

    it { is_expected.to be_valid }
  end

  context 'with over the minimum number of chars' do
    let(:string_value) { 'aaaa' }

    it { is_expected.to be_valid }
  end

  context 'with less chars than minimum' do
    let(:string_value) { 'aa' }

    it { is_expected.not_to be_valid }
    it { is_expected.to have_activemodel_error_type(:string_field, :too_short) }
  end

  context 'with less chars than minimum plus whitespace' do
    let(:string_value) { "\s\sa\sa\s\s\t" }

    it { is_expected.not_to be_valid }
    it { is_expected.to have_activemodel_error_type(:string_field, :too_short) }
  end

  context 'with no message option' do
    let(:foo_model) do
      Class.new do
        include ActiveModel::Model

        def self.name
          'FooModel'
        end

        attr_accessor :string_field

        validates :string_field,
                  char_length: { minimum: 10 }
      end
    end

    context 'with invalid value' do
      let(:string_value) { 'a' }

      it {
        is_expected
          .to have_activemodel_error_message(:string_field, 'is too short (minimum is 10 characters)')
      }
    end
  end

  context 'with message option' do
    let(:foo_model) do
      Class.new do
        include ActiveModel::Model

        def self.name
          'FooModel'
        end

        attr_accessor :string_field

        validates :string_field,
                  char_length: { minimum: 3, message: 'that is too short!' }
      end
    end

    context 'with invalid value' do
      let(:string_value) { 'a' }

      it { is_expected.to have_activemodel_error_message(:string_field, 'that is too short!') }
    end
  end
end
