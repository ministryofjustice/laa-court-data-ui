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
        before do
          allow(offence).to receive(:mode_of_trial_reason).and_return('Court directs trial by jury')
        end

        it 'displays mode of trial with reason' do
          render
          expect(rendered).to have_css('.govuk-table__cell',
                                       text: /Indictable only:\n*Court directs trial by jury/)
        end
      end

      context 'without reason' do
        before { allow(offence).to receive(:mode_of_trial_reason).and_return(nil) }

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

    context 'when the offence has plea details' do
      before do
        allow(offence).to receive(:plea).and_return('NOT_GUILTY')
        allow(offence).to receive(:plea_date).and_return('2020-04-12')
        allow(offence).to receive(:plea_and_date).and_call_original
      end

      it 'displays plea and plea date' do
        render
        expect(rendered).to have_css('.govuk-table__cell', text: 'Not guilty on 12/04/2020')
      end
    end

    context 'when the offence has no plea details' do
      before do
        allow(offence).to receive(:plea).and_return(nil)
        allow(offence).to receive(:plea_date).and_return(nil)
        allow(offence).to receive(:plea_and_date).and_call_original
      end

      it 'displays Not available for plea and plea date' do
        render
        expect(rendered).to have_css('.govuk-table__cell:nth-of-type(2)', text: 'Not available')
      end
    end
  end
end
