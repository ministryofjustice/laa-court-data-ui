# frozen_string_literal: true

RSpec.describe "defendants/_unlink.html.haml", type: :view do
  let(:defendant_id) { SecureRandom.uuid }
  let(:defendant) { instance_double(Cda::Defendant, id: defendant_id) }
  let(:prosecution_case_reference) { "TEST12345" }
  let(:form_model) { UnlinkAttempt.new }

  before do
    allow(view).to receive(:default_form_builder).and_return(GOVUKDesignSystemFormBuilder::FormBuilder)

    create(:unlink_reason, code: 1, description: "Linked to wrong case ID (correct defendant)")
    create(:unlink_reason, code: UnlinkReason::OTHER_REASON_CODE, description: "Other")
  end

  subject(:render_partial) do
    render partial: "defendants/unlink",
           locals: { form_model:, defendant:, prosecution_case_reference: }
  end

  it "renders the unlink form with its reason options and warning" do
    render_partial

    expect(rendered).to have_css(
      "form#unlink_form[action='/defendants/#{defendant_id}/unlink?urn=#{prosecution_case_reference}'][data-turbo='false']",
    )
    expect(rendered).to have_css("h2", text: I18n.t("defendants.unlink.title"))
    expect(rendered).to have_field("unlink_attempt[reason_code]", type: "radio", with: "1")
    expect(rendered).to have_field("unlink_attempt[reason_code]", type: "radio", with: "7")
    expect(rendered).to have_css(".govuk-warning-text__text", text: I18n.t("defendants.unlink.warning"))
    expect(rendered).to have_button(
      I18n.t("defendants.unlink.submit"),
      class: "govuk-button--warning",
      disabled: false,
    )
  end

  it "renders the additional reason text field for the other reason" do
    render_partial

    expect(rendered).to have_field("unlink_attempt[other_reason_text]", type: "textarea")
    expect(rendered).to have_text("You can enter up to 500 characters")
    expect(rendered).to have_text(I18n.t("defendants.form.other_reason_text.hint"))
    expect(rendered).to have_text(I18n.t("defendants.form.other_reason_text.label"))
  end
end
