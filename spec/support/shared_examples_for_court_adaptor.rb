# frozen_string_literal: true

RSpec.shared_examples 'court_data_adaptor queryable object' do
  it { is_expected.to respond_to :acts_as_resource, :resource }
  it { expect(subject.new(nil)).to respond_to :resource }
end

RSpec.shared_examples 'court_data_adaptor query object' do
  it { is_expected.to respond_to :call }
  it { expect(subject.new(nil)).to respond_to :call, :term }
end
