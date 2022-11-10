# frozen_string_literal: true

RSpec.describe UnlinkReason, type: :model do
  subject(:unlink_reason) { create(:unlink_reason) }

  it { is_expected.to respond_to(:code, :description, :text_required, :text_required?) }

  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_uniqueness_of(:description).case_insensitive }
end
