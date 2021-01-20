# frozen_string_literal: true

RSpec.describe 'defendants/_offences.html.haml', type: :view do
  let(:defendant) { object_double(CourtDataAdaptor::Resource::Defendant.new, offences: [offence]) }
  let(:offence) { CourtDataAdaptor::Resource::Offence.new }

  before do
    assign(:defendant, defendant)
  end

  context 'when the defendant has an offence' do
    context 'when the offence has a mode of trial' do
      before { allow(offence).to receive(:mode_of_trial).and_return('Indictable only') }

      context 'with reason' do
        let(:mot_reason_ostruct_collection) { mot_reasons_array.map { |el| OpenStruct.new(el) } }

        let(:mot_reasons_array) do
          [{ code: '4', description: 'Defendant elects trial by jury' }]
        end

        before do
          allow(offence).to receive(:mode_of_trial_reasons).and_return(mot_reason_ostruct_collection)
        end

        it 'displays mode of trial with reason' do
          render
          expect(rendered).to have_css('.govuk-table__cell',
                                       text: /Indictable only:\n*Defendant elects trial by jury/)
        end
      end

      context 'without reason' do
        before { allow(offence).to receive(:mode_of_trial_reasons).and_return(nil) }

        it 'displays mode of trial without reason' do
          render
          expect(rendered).to have_css('.govuk-table__cell', text: /Indictable only:\n*Not available/)
        end
      end
    end

    context 'when the offence has a title' do
      before { allow(offence).to receive(:title).and_return('Murder') }

      it 'displays offence title' do
        render
        expect(rendered).to have_css('.govuk-table__cell', text: 'Murder')
      end
    end

    context 'when the offence has no title' do
      before { allow(offence).to receive(:title).and_return(nil) }

      it 'displays not available' do
        render
        expect(rendered).to have_css('.govuk-table__cell:nth-of-type(1)', text: 'Not available')
      end
    end

    context 'when the offence has legislation' do
      before { allow(offence).to receive(:legislation).and_return('Proceeds of Crime Act 2002 s.331') }

      it 'displays offence legislation' do
        render
        expect(rendered).to have_css('.app-body-secondary', text: 'Proceeds of Crime Act 2002 s.331')
      end
    end

    context 'when the offence has no legislation' do
      before { allow(offence).to receive(:legislation).and_return(nil) }

      it 'displays not available' do
        render
        expect(rendered).to have_css('.app-body-secondary', text: 'Not available')
      end
    end

    context 'when the offence has pleas' do
      let(:plea_ostruct_collection) { plea_array.map { |el| OpenStruct.new(el) } }

      let(:plea_array) do
        [{ code: 'NOT_GUILTY',
           pleaded_at: '2020-04-12' },
         { code: 'GUILTY',
           pleaded_at: '2020-05-12' },
         { code: 'NO_PLEA',
           pleaded_at: '2020-03-12' }]
      end

      before do
        allow(offence).to receive(:pleas).and_return(plea_ostruct_collection)
      end

      it 'displays list of pleas with plea dates' do
        render
        expect(rendered)
          .to have_css('.govuk-table__cell',
                       text: %r{No plea on 12/03/2020.*Not guilty on 12/04/2020.*Guilty on 12/05/2020})
      end
    end

    context 'when the offence has no pleas' do
      before do
        allow(offence).to receive(:pleas).and_return([])
      end

      it 'displays Not available for plea and plea date' do
        render
        expect(rendered).to have_css('.govuk-table__cell:nth-of-type(2)', text: 'Not available')
      end
    end
  end
end
