# frozen_string_literal: true

RSpec.describe SearchFilter, type: :model do
  subject { described_class.new }

  it {
    expect(subject).to \
      respond_to(:id, :id=,
                 :name, :name=,
                 :description, :description=)
  }
end
