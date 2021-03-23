# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  include ViewSpecHelper
  include ActionView::Helpers

  subject { helper }

  it { is_expected.to respond_to :govuk_page_title }
  it { is_expected.to respond_to :govuk_breadcrumb_builder }
  it { is_expected.to respond_to :service_name }
  it { is_expected.to respond_to :l }
  it { is_expected.to respond_to :decorate }
  it { is_expected.to respond_to :decorate_all }

  shared_context 'with mock objects and decorators' do
    let(:test_objects) { [test_class.new, test_class.new] }
    let(:test_object) { test_class.new }
    let(:view_object) { view_class.new }
    let(:view_class) { Class.new }

    let(:test_class) do
      Class.new do
        def my_string
          'hi'
        end
      end
    end

    let(:test_class_decorator) do
      Class.new(BaseDecorator) do
        def my_upcased_string
          my_string.upcase
        end
      end
    end

    let(:other_class_decorator) do
      Class.new(BaseDecorator) do
        def my_bold_string
          '<b>my_string</b>'
        end
      end
    end
  end

  describe '#decorate' do
    include_context 'with mock objects and decorators'

    shared_examples 'returns or yields decorated object' do
      subject(:decorated_object) { helper.decorate(test_object) }

      before do
        stub_const('TestClassDecorator', test_class_decorator)
      end

      it { is_expected.to be_instance_of(test_class_decorator) }
      it { is_expected.to respond_to(:my_string, :my_upcased_string) }
      it { expect { |b| decorate(test_object, &b) }.to yield_with_args(instance_of(test_class_decorator)) }

      it 'sends view context to decorator' do
        allow(test_class_decorator).to receive(:new)
        helper.decorate(test_object)
        expect(test_class_decorator).to have_received(:new).with(test_object, helper)
      end
    end

    context 'when called with no decorator class' do
      context 'with unmodularized class' do
        before { stub_const('TestClass', test_class) }

        include_examples 'returns or yields decorated object'
      end

      context 'with modularized class' do
        before { stub_const('TestModule::TestClass', test_class) }

        include_examples 'returns or yields decorated object'
      end
    end

    context 'when called with a decorator class' do
      subject(:decorated_object) { helper.decorate(test_object, other_class_decorator) }

      before do
        stub_const('TestClass', test_class)
        stub_const('OtherClassDecorator', other_class_decorator)
      end

      it { is_expected.to be_instance_of(other_class_decorator) }
      it { is_expected.to respond_to(:my_string, :my_bold_string) }

      it {
        expect { |b| decorate(test_object, other_class_decorator, &b) }
          .to yield_with_args(instance_of(other_class_decorator))
      }
    end

    context 'when called with a nil object' do
      subject(:decorated_object) { helper.decorate(nil) }

      it { is_expected.to be_instance_of(NilClass) }
      it { expect { |b| decorate(nil, &b) }.not_to yield_control }
    end

    context 'when called with a decorated object' do
      subject(:decorated_object) { helper.decorate(already_decorated_object) }

      let(:already_decorated_object) { helper.decorate(test_class.new) }

      before do
        stub_const('TestClass', test_class)
        stub_const('TestClassDecorator', test_class_decorator)
      end

      it { is_expected.to be_instance_of(test_class_decorator) }
      it { expect { |b| decorate(test_object, &b) }.to yield_with_args(instance_of(test_class_decorator)) }
    end
  end

  describe '#decorate_all' do
    include_context 'with mock objects and decorators'

    shared_examples 'returns or yields all decorated objects' do
      subject(:decorated_objects) { helper.decorate_all(test_objects) }

      before do
        stub_const('TestClassDecorator', test_class_decorator)
      end

      it { is_expected.to all(be_instance_of(test_class_decorator)) }
      it { is_expected.to all(respond_to(:my_string, :my_upcased_string)) }

      it {
        expect { |b| decorate_all(test_objects, &b) }
          .to yield_successive_args(instance_of(test_class_decorator),
                                    instance_of(test_class_decorator))
      }

      it 'sends view context to decorator' do
        allow(test_class_decorator).to receive(:new)
        helper.decorate_all(test_objects)
        expect(test_class_decorator).to have_received(:new).with(instance_of(test_class), helper).twice
      end
    end

    it 'aliased as #decorate_each' do
      expect(helper.method(:decorate_all)).to eql(helper.method(:decorate_each))
    end

    context 'when called with no decorator class' do
      context 'with unmodularized class' do
        before { stub_const('TestClass', test_class) }

        include_examples 'returns or yields all decorated objects'
      end

      context 'with modularized class' do
        before { stub_const('TestModule::TestClass', test_class) }

        include_examples 'returns or yields all decorated objects'
      end
    end

    context 'when called with a decorator class' do
      subject(:decorated_object) { helper.decorate_all(test_objects, other_class_decorator) }

      before do
        stub_const('TestClass', test_class)
        stub_const('OtherClassDecorator', other_class_decorator)
      end

      it { is_expected.to all(be_instance_of(other_class_decorator)) }
      it { is_expected.to all(respond_to(:my_string, :my_bold_string)) }

      it {
        expect { |b| decorate_all(test_objects, other_class_decorator, &b) }
          .to yield_successive_args(instance_of(other_class_decorator), instance_of(other_class_decorator))
      }
    end
  end

  describe '#hearings_sorter_link' do
    subject(:hearings_sorter_link) { helper.hearings_sorter_link(id, column) }

    let(:sort_column) { 'date' }
    let(:sort_direction) { 'asc' }
    let(:column) { 'provider' }
    let(:id) { 'TEST12345' }

    before do
      initialize_view_helpers(helper)
      allow(helper).to receive(:sort_column).and_return sort_column
      allow(helper).to receive(:sort_direction).and_return sort_direction
    end

    context 'when column is provider and sort_column is date' do
      it {
        is_expected.to have_link('Providers attending',
                                 href: '/prosecution_cases/TEST12345?column=provider&direction=desc',
                                 class: 'govuk-link')
      }
    end

    context 'when sort_column is provider, sort_column is provider, sort_direction is asc' do
      let(:sort_column) { 'provider' }

      it {
        is_expected.to have_link("Providers attending \u25B2",
                                 href: '/prosecution_cases/TEST12345?column=provider&direction=desc',
                                 class: 'govuk-link')
      }
    end

    context 'when sort_column is provider, sort_column is provider, sort_direction is desc' do
      let(:sort_column) { 'provider' }
      let(:sort_direction) { 'desc' }

      it {
        is_expected.to have_link("Providers attending \u25BC",
                                 href: '/prosecution_cases/TEST12345?column=provider&direction=asc',
                                 class: 'govuk-link')
      }
    end
  end
end
