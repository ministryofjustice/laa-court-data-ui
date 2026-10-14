# frozen_string_literal: true

RSpec.describe "link_migrated_cases/_offences.html.haml", type: :view do
  subject(:render_partial) do
    render partial: "link_migrated_cases/offences", locals:
  end

  let(:locals) { { defendant:, offence_history_collection:, offence_ids: } }
  let(:offence_ids) { nil }
  let(:defendant) { Cda::Defendant.new(offence_summaries: [offence]) }
  let(:offence) do
    Cda::OffenceSummary.new(id: "123", start_date:, mode_of_trial:, title:, legislation:)
  end
  let(:offence_history_collection) { Cda::OffenceHistoryCollection.new(offence_histories: [offence_history]) }
  let(:offence_history) { Cda::OffenceHistory.new(id: "123", pleas:, mode_of_trial_reasons:, verdict:) }
  let(:start_date) { nil }
  let(:mode_of_trial_reasons) { nil }
  let(:title) { nil }
  let(:pleas) { [] }
  let(:mode_of_trial) { "Indictable only" }
  let(:legislation) { nil }
  let(:verdict) { nil }

  context "when the defendant has an offence" do
    context "when offence has a start date" do
      let(:start_date) { "2023-01-01" }

      it "displays offence start date" do
        expect(render_partial).to have_css(".govuk-table__cell", text: %r{01/01/2023})
      end
    end

    context "when offence has no start date" do
      it "displays not available" do
        expect(render_partial).to have_css(".govuk-table__cell:nth-of-type(1)", text: "Not available")
      end
    end

    context "when the offence has a title and legislation" do
      let(:title) { "Murder" }
      let(:legislation) { "Proceeds of Crime Act 2002 s.331" }

      it "displays the title" do
        expect(render_partial).to have_css(".govuk-table__cell", text: "Murder")
      end

      it "displays the legislation" do
        expect(render_partial).to have_css(".app-body-secondary", text: "Proceeds of Crime Act 2002 s.331")
      end
    end

    context "when the offence has no title or legislation" do
      it "displays not available for both" do
        expect(render_partial).to have_css(".govuk-table__cell:nth-of-type(2)", text: /Not available.*Not available/m)
      end
    end

    context "when the offence has pleas" do
      let(:pleas) do
        [{ code: "NOT_GUILTY", pleaded_at: "2020-04-12" },
         { code: "GUILTY", pleaded_at: "2020-05-12" },
         { code: "NO_PLEA", pleaded_at: "2020-03-12" }].map { |el| Cda::Plea.new(el) }
      end

      it "displays list of pleas with plea dates" do
        expect(render_partial)
          .to have_css(".govuk-table__cell",
                       text: %r{No plea on 12 March 2020.*Not guilty on 12 April 2020.*Guilty on 12 May 2020})
      end
    end

    context "when the offence has no pleas" do
      it "displays not available for plea" do
        expect(render_partial).to have_css(".govuk-table__cell:nth-of-type(3)", text: "Not available")
      end
    end

    context "when the offence has a mode of trial with reason" do
      let(:mode_of_trial_reasons) do
        [Cda::BaseModel.new(code: "4", description: "Defendant elects trial by jury")]
      end

      it "displays mode of trial with reason" do
        expect(render_partial).to have_css(".govuk-table__cell",
                                           text: /Indictable only:\n*Defendant elects trial by jury/)
      end
    end

    context "when the offence has a mode of trial without reason" do
      it "displays mode of trial without reason" do
        expect(render_partial).to have_css(".govuk-table__cell", text: /Indictable only:\n*Not available/)
      end
    end

    context "when the offence has a verdict" do
      let(:verdict) { "Guilty" }

      it "displays the verdict" do
        expect(render_partial).to have_css(".govuk-table__cell:nth-of-type(5)", text: "Guilty")
      end
    end

    context "when the offence has no verdict" do
      it "displays not available for verdict" do
        expect(render_partial).to have_css(".govuk-table__cell:nth-of-type(5)", text: "Not available")
      end
    end

    context "when offence histories have not loaded" do
      let(:offence_history_collection) { nil }

      it "displays loading for plea, mode of trial and verdict" do
        expect(render_partial).to have_css(".govuk-table__cell", text: "Loading...", count: 3)
      end
    end
  end

  it "renders the table headers" do
    render_partial
    expect(rendered).to have_css("th.govuk-table__header", count: 5)
    expect(rendered).to have_css("th.govuk-table__header", text: "Verdict")
  end

  context "when there is one offence" do
    it "displays the heading with a count of offences" do
      expect(render_partial).to have_css(".govuk-heading-m", text: "Offences (1)")
    end
  end

  context "when there are multiple offences" do
    let(:defendant) { Cda::Defendant.new(offence_summaries: [offence, offence, offence]) }

    it "displays the heading with a count of offences" do
      expect(render_partial).to have_css(".govuk-heading-m", text: "Offences (3)")
    end
  end

  context "when offence_ids filters the offences" do
    let(:other_offence) { Cda::OffenceSummary.new(id: "456", title: "Theft", start_date: nil, legislation: nil, mode_of_trial:) }
    let(:defendant) { Cda::Defendant.new(offence_summaries: [offence, other_offence]) }
    let(:offence) { Cda::OffenceSummary.new(id: "123", title: "Murder", start_date: nil, legislation: nil, mode_of_trial:) }
    let(:offence_ids) { %w[123] }

    it "only displays the matching offences" do
      expect(render_partial).to have_css(".govuk-heading-m", text: "Offences (1)")
      expect(rendered).to have_css(".govuk-table__cell", text: "Murder")
      expect(rendered).to have_no_css(".govuk-table__cell", text: "Theft")
    end
  end

  context "when the defendant has no offences" do
    let(:defendant) { Cda::Defendant.new(offence_summaries: []) }

    it "displays the no offences message and no table" do
      expect(render_partial).to have_css(".govuk-body", text: "No offences are associated with this case")
      expect(rendered).to have_no_css("table")
    end
  end
end
