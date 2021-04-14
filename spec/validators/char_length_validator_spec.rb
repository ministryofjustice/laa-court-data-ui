# frozen_string_literal: true

RSpec.describe CharLengthValidator, type: :validator do
  subject(:model_instance) { foo_model.new(string_field: string_value) }

  let(:foo_model) do
    Class.new do
      include ActiveModel::Model

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

    it { is_expected.to be_invalid }
    it { is_expected.to have_activemodel_error_type(:string_field, :too_short) }
  end

  context 'with less chars than minimum plus whitespace' do
    let(:string_value) { "\s\sa\sa\s\s\t" }

    it { is_expected.to be_invalid }
    it { is_expected.to have_activemodel_error_type(:string_field, :too_short) }
  end
end
