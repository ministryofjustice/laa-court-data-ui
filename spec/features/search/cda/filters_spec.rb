# frozen_string_literal: true

RSpec.feature "Search filters", :js, type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  scenario "user visits search filter options" do
    visit "/"

    expect(page).to have_css("legend", text: "Search for")
    expect(page).to have_css(".govuk-radios__item",
                             text: "A case by URN\nU R N")
    expect(page).to have_css(".govuk-radios__item",
                             text: "A defendant by ASN\nA S N\n or National insurance number")
    expect(page).to have_css(".govuk-radios__item",
                             text: "A defendant by name and date of birth")
    expect(page).to have_css(".govuk-radios__item",
                             text: "A migrated case by Xhibit reference")

    expect(page).to be_accessible
  end

  scenario "user chooses defendant ASN or NI filter" do
    visit "/"

    choose "A defendant by ASN"
    click_link_or_button "Continue"
    expect(page).to have_text("Defendant ASN\nA S N\n or National insurance number")

    expect(page).to be_accessible
  end

  scenario "user chooses defendant name filter" do
    visit "/"

    choose "A defendant by name and date of birth"
    click_link_or_button "Continue"
    expect(page).to have_text("Defendant name")

    expect(page).to be_accessible
  end

  scenario "user chooses case number filter" do
    visit "/"

    choose "A case by URN"
    click_link_or_button "Continue"
    expect(page).to have_text("Unique reference number")

    expect(page).to be_accessible
  end

  scenario "user chooses Xhibit reference filter" do
    visit "/"

    choose "A migrated case by Xhibit reference"
    click_link_or_button "Continue"
    expect(page).to have_text("Xhibit case reference")

    expect(page).to be_accessible
  end

  scenario "user visits search filter options when the search by Xhibit ref flag is disabled" do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:search_by_xhibit_ref_flag).and_return(false)

    visit "/"

    expect(page).to have_css(".govuk-radios__item", text: "A case by URN\nU R N")
    expect(page).to have_no_css(".govuk-radios__item", text: "A migrated case by Xhibit reference")
  end
end
