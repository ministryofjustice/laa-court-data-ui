# frozen_string_literal: true

RSpec.describe TagsHelper, type: :helper do
  describe "#case_type_tag" do
    it "returns nil for blank `case_type`" do
      expect(helper.case_type_tag(nil)).to be_nil
      expect(helper.case_type_tag("")).to be_nil
      expect(helper.case_type_tag("   ")).to be_nil
    end

    context "when `case_type` is mapped" do
      it 'renders `Trial` tag for "T"' do
        expect(helper.case_type_tag("T"))
          .to eq('<strong class="govuk-tag govuk-tag--blue">Trial</strong>')
      end

      it "is case insensitive" do
        expect(helper.case_type_tag("t"))
          .to eq('<strong class="govuk-tag govuk-tag--blue">Trial</strong>')
      end

      it "uses the provided text" do
        expect(helper.case_type_tag("T", text: "Custom"))
          .to eq('<strong class="govuk-tag govuk-tag--blue">Custom</strong>')
      end

      it 'renders `Breach/POCA` tag for "S"' do
        expect(helper.case_type_tag("S"))
          .to eq('<strong class="govuk-tag govuk-tag--yellow">Breach/POCA</strong>')
      end

      it 'renders `Appeal` tag for "A"' do
        expect(helper.case_type_tag("A"))
          .to eq('<strong class="govuk-tag govuk-tag--purple">Appeal</strong>')
      end
    end

    context "when `case_type` is unknown" do
      it "renders a grey tag with the given parameter" do
        expect(helper.case_type_tag("X"))
          .to eq('<strong class="govuk-tag govuk-tag--grey">X</strong>')
      end
    end
  end
end
