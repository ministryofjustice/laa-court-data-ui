# frozen_string_literal: true

RSpec.describe "shared/_unlink.html.haml", type: :view do
  let(:form_model) { UnlinkAttempt.new }
  let(:url) { "/unlink" }
  let(:cancel_url) { "/cancel" }

  before do
    allow(view).to receive(:default_form_builder).and_return(GOVUKDesignSystemFormBuilder::FormBuilder)

    create(:unlink_reason, code: 1, description: "Linked to wrong case ID (correct defendant)")
    create(:unlink_reason, code: UnlinkReason::OTHER_REASON_CODE, description: "Other")
  end

  subject(:render_partial) do
    render partial: "shared/unlink",
           locals: { form_model:, url:, cancel_url: }
  end

  it "renders the unlink form with its reason options and warning" do
    render_partial

    expect(rendered).to have_css(
      "form#unlink_form[action='#{url}'][data-turbo='false']",
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
    expect(rendered).to have_link(I18n.t("defendants.unlink.cancel"), href: cancel_url)
  end

  it "renders the additional reason text field for the other reason" do
    render_partial

    expect(rendered).to have_field("unlink_attempt[other_reason_text]", type: "textarea")
    expect(rendered).to have_text("You can enter up to 500 characters")
    expect(rendered).to have_text(I18n.t("defendants.form.other_reason_text.hint"))
    expect(rendered).to have_text(I18n.t("defendants.form.other_reason_text.label"))
  end
end
