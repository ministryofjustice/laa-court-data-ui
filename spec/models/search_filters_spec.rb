# frozen_string_literal: true

RSpec.describe SearchFilter, type: :model do
  subject { described_class.new }

  it {
    is_expected.to \
      respond_to(:id, :id=,
                 :name, :name=,
                 :description, :description=)
  }
end
