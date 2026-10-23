# frozen_string_literal: true

RSpec.describe UnlinkReason, type: :model do
  subject(:unlink_reason) { create(:unlink_reason, description: "Some description") }

  it { is_expected.to respond_to(:code, :description, :text_required?) }

  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_uniqueness_of(:description).case_insensitive }

  describe "#description" do
    it "replaces supported acronyms with their accessible translations" do
      unlink_reason = build(:unlink_reason, description: "URN, MAAT and POCA")

      expect(unlink_reason.description).to eq(
        "#{I18n.t('acronyms.urn_html')}, #{I18n.t('acronyms.maat_html')} and #{I18n.t('acronyms.poca_html')}",
      )
    end

    it "does not interpret other description content as HTML" do
      unlink_reason = build(:unlink_reason, description: "<b>URN</b>")

      expect(unlink_reason.description).to include("&lt;b&gt;")
      expect(unlink_reason.description).to include(I18n.t("acronyms.urn_html"))
      expect(unlink_reason.description).not_to include("<b>")
    end
  end
end
