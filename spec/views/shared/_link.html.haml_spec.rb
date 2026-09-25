# frozen_string_literal: true

RSpec.describe "shared/_link.html.haml", type: :view do
  let(:form_model) { LinkAttempt.new }
  let(:url) { "/link" }

  before do
    allow(view).to receive(:default_form_builder).and_return(GOVUKDesignSystemFormBuilder::FormBuilder)
  end

  def render_partial(**locals)
    render partial: "shared/link", locals: { url:, form_model: }.merge(locals)
  end

  it "renders the heading and linking form" do
    render_partial

    expect(rendered).to have_css("div.govuk-heading-m", text: I18n.t("generic.link_court_data"))
    expect(rendered).to have_css('form[action="/link"][data-turbo-stream="true"]')
    expect(rendered).to have_field("link_attempt[maat_reference]")
    expect(rendered).to have_css("label", text: I18n.t("laa_reference.link.form.maat_reference.label"))
    expect(rendered).to have_button(I18n.t("laa_reference.link.form.submit"),
                                    name: "maat_ref_required", value: "true")
    expect(rendered).to have_text(I18n.t("laa_reference.missing_maat_id.submit"))
  end

  it "renders the hint and inset text when provided" do
    render_partial hint: "Enter the seven-digit reference", inset_text: "This creates a link."

    expect(rendered).to have_text("Enter the seven-digit reference")
    expect(rendered).to have_css(".govuk-inset-text", text: "This creates a link.")
  end

  it "renders the secondary link when provided" do
    render_partial secondary_link: { text: "Cancel", url: "/cancel" }

    expect(rendered).to have_link("Cancel", href: "/cancel", class: "govuk-link")
  end

  it "omits the heading and secondary link when they are not enabled" do
    render_partial show_heading: false

    expect(rendered).to have_no_css("div.govuk-heading-m")
    expect(rendered).to have_no_link("Cancel")
  end

  it "renders the missing MAAT ID details" do
    render_partial

    expect(rendered).to have_css("details")
    expect(rendered).to have_text(I18n.t("laa_reference.missing_maat_id.label"))
    expect(rendered).to have_text(I18n.t("laa_reference.missing_maat_id.description"))
  end
end
