# frozen_string_literal: true

RSpec.describe NilClassDecorator, type: :decorator do
  subject(:decorator) { described_class.new(nil, view_object) }

  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { nil }
  end

  it { expect(decorator).to be_falsey }
  it { expect(decorator).to be_nil }
  it { expect(decorator).to be_blank }
  it { expect(decorator).not_to be_present }
end
