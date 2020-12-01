# frozen_string_literal: true

RSpec.describe BaseDecorator, type: :decorator do
  subject(:decorator) { test_decorator_class.new(test_object, view_object) }

  let(:test_object) { test_class.new }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers::TranslationHelper
    end
  end

  let(:test_class) do
    Class.new do
      def my_string
        'hi'
      end
    end
  end

  let(:test_decorator_class) do
    Class.new(BaseDecorator) do
      def my_upcased_string
        my_string.upcase
      end
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { test_object }
  end

  it { is_expected.to respond_to(:my_string) }

  describe '#my_string' do
    subject { decorator.my_string }

    it { is_expected.to eql 'hi' }
  end

  describe '#my_upcased_string' do
    subject { decorator.my_upcased_string }

    it { is_expected.to eql('HI') }
  end
end
