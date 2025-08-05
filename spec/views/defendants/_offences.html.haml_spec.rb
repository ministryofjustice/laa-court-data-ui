# frozen_string_literal: true

RSpec.describe 'defendants/_offences.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'defendants/offences', locals: { defendant:, offence_history_collection: }
  end

  let(:defendant) { Cda::Defendant.new(offence_summaries: [offence]) }
  let(:offence) do
    Cda::OffenceSummary.new(id: '123', start_date:, mode_of_trial:, title:, legislation:)
  end
  let(:offence_history_collection) { Cda::OffenceHistoryCollection.new(offence_histories: [offence_history]) }
  let(:offence_history) { Cda::OffenceHistory.new(id: '123', pleas:, mode_of_trial_reasons:) }
  let(:start_date) { nil }
  let(:mode_of_trial_reasons) { nil }
  let(:title) { nil }
  let(:pleas) { [] }
  let(:mode_of_trial) { 'Indictable only' }
  let(:legislation) { nil }

  context 'when the defendant has an offence' do
    context 'when offence has a start date' do
      let(:start_date) { '2023-01-01' }

      it 'displays offence start date' do
        is_expected.to have_css('.govuk-table__cell',
                                text: %r{01/01/2023})
      end
    end

    context 'when offence has no start date' do
      it 'displays no offence start date' do
        is_expected.to have_css('.govuk-table__cell',
                                text: /Not available/)
      end
    end

    context 'when the offence has a mode of trial' do
      context 'with reason' do
        let(:mode_of_trial_reasons) do
          mot_reasons_array.map { |el| Cda::BaseModel.new(el) }
        end

        let(:mot_reasons_array) do
          [{ code: '4', description: 'Defendant elects trial by jury' }]
        end

        it 'displays mode of trial with reason' do
          is_expected.to have_css('.govuk-table__cell',
                                  text: /Indictable only:\n*Defendant elects trial by jury/)
        end
      end

      context 'without reason' do
        it 'displays mode of trial without reason' do
          is_expected.to have_css('.govuk-table__cell', text: /Indictable only:\n*Not available/)
        end
      end
    end

    context 'when the offence has a title' do
      let(:title) { 'Murder' }

      it 'displays offence title' do
        is_expected.to have_css('.govuk-table__cell', text: 'Murder')
      end
    end

    context 'when the offence has no title' do
      it 'displays not available' do
        is_expected.to have_css('.govuk-table__cell:nth-of-type(1)', text: 'Not available')
      end
    end

    context 'when the offence has legislation' do
      let(:legislation) { 'Proceeds of Crime Act 2002 s.331' }

      it 'displays offence legislation' do
        is_expected.to have_css('.app-body-secondary', text: 'Proceeds of Crime Act 2002 s.331')
      end
    end

    context 'when the offence has no legislation' do
      it 'displays not available' do
        is_expected.to have_css('.app-body-secondary', text: 'Not available')
      end
    end

    context 'when the offence has pleas' do
      let(:pleas) do
        plea_array.map { |el| Cda::Plea.new(el) }
      end

      let(:plea_array) do
        [{ code: 'NOT_GUILTY',
           pleaded_at: '2020-04-12' },
         { code: 'GUILTY',
           pleaded_at: '2020-05-12' },
         { code: 'NO_PLEA',
           pleaded_at: '2020-03-12' }]
      end

      it 'displays list of pleas with plea dates' do
        is_expected
          .to have_css('.govuk-table__cell',
                       text: %r{No plea on 12/03/2020.*Not guilty on 12/04/2020.*Guilty on 12/05/2020})
      end
    end

    context 'when the offence has no pleas' do
      it 'displays Not available for plea and plea date' do
        is_expected.to have_css('.govuk-table__cell:nth-of-type(2)', text: 'Not available')
      end
    end
  end
end
