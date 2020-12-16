# frozen_string_literal: true

RSpec.describe 'prosecution_cases/_cracked_ineffective_trial.html.haml', type: :view do
  subject(:render_partial) { render partial: 'cracked_ineffective_trial', locals: { results: results } }

  include RSpecHtmlMatchers

  let(:results) { [prosecution_case] }
  let(:prosecution_case) do
    CourtDataAdaptor::Resource::ProsecutionCase.new(prosecution_case_reference: 'THECASEURN')
  end
  let(:hearings) { [hearing] }
  let(:hearing) do
    CourtDataAdaptor::Resource::Hearing.new(id: 'the-hearing-uuid',
                                            hearing_type: 'Trial (TR)')
  end
  let(:cracked_ineffective_trial) { CourtDataAdaptor::Resource::CrackedIneffectiveTrial.new(id: 'a-uuid') }

  before do
    allow(prosecution_case).to receive(:hearings).and_return(hearings)
    allow(hearing).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial)
  end

  context 'when any hearing has a cracked ineffective trial' do
    context 'with a type of cracked' do
      before do
        allow(cracked_ineffective_trial).to receive(:type).and_return('Cracked')
      end

      it 'displays case result section' do
        render_partial
        expect(rendered).to have_tag('th.govuk-table__header', text: /Case results/)
      end

      it 'displays the cracked_ineffective_trial type' do
        render_partial
        expect(rendered).to have_tag('td.govuk-table__cell', text: /Cracked during/)
      end

      it 'displays link to hearing' do
        render_partial
        expect(rendered).to have_tag('a', with: { href: '/hearings/the-hearing-uuid?urn=THECASEURN' }) do
          with_text(/Trial \(TR\)/)
        end
      end
    end

    # TODO
    # context 'with a type of vacated', skip: '# TODO' do
    #   before { allow(prosecution_case).to receive(:type).and_return 'vacated' }

    #   context 'and the code indicates a "crack" of the trial' do
    #   end

    #   context 'and the code does NOT indicate a "crack" of the trial' do
    #   end
    # end

    # context 'with a type of ineffective', skip: '# TODO' do
    #   before { allow(prosecution_case).to receive(:type).and_return 'ineffective' }
    # end
  end
end
