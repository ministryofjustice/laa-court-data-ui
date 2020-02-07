# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Resource::Queryable, :concern do
  let(:test_class) do
    Class.new do
      include CourtDataAdaptor::Resource::Queryable
      acts_as_resource :my_resource_class
    end
  end

  describe '.acts_as_resource' do
    before { test_class.acts_as_resource :funky_resource_class }

    it 'defines resource class constant on the class' do
      expect(test_class.resource).to be :funky_resource_class
    end
  end

  describe '.resource' do
    subject { test_class.resource }

    it { is_expected.to be :my_resource_class }
  end

  describe '#resource' do
    subject { test_class.new.resource }

    it { is_expected.to be :my_resource_class }
  end
end
