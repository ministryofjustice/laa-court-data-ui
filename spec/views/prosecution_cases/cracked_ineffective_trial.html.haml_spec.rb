# frozen_string_literal: true

RSpec.shared_examples 'cracked_ineffective_trial with case level result' do |options|
  include RSpecHtmlMatchers

  let(:type_text) { options.fetch(:type_text) }

  it 'displays case result section' do
    render_partial
    expect(rendered).to have_tag('th.govuk-table__header', text: /Case results/)
  end

  it 'displays the cracked_ineffective_trial type' do
    render_partial
    expect(rendered).to have_tag('td.govuk-table__cell', text: /#{type_text} on/)
  end

  it 'displays link to hearing' do
    render_partial
    expect(rendered).to have_tag('a', with: { href: '/hearings/the-hearing-uuid?urn=THECASEURN' }) do
      with_text(%r{15/01/2021})
    end
  end

  it 'displays reason' do
    render_partial
    expect(rendered).to have_tag('td.govuk-table__cell') do
      with_text(/Reason for cracked, vacated or ineffective trial/)
    end
  end
end

RSpec.describe 'prosecution_cases/_cracked_ineffective_trial.html.haml', type: :view do
  subject(:render_partial) { render partial: 'cracked_ineffective_trial', locals: { results: results } }

  include RSpecHtmlMatchers

  let(:results) { [prosecution_case] }
  let(:prosecution_case) do
    CourtDataAdaptor::Resource::ProsecutionCase
      .new(prosecution_case_reference: 'THECASEURN')
  end
  let(:hearings) { [hearing] }
  let(:hearing) do
    CourtDataAdaptor::Resource::Hearing
      .new(id: 'the-hearing-uuid',
           hearing_days: ['2021-01-15T13:19:15.000Z'])
  end

  before do
    allow(prosecution_case).to receive(:hearings).and_return(hearings)
    allow(hearing).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial)
  end

  context 'when any hearing has a cracked ineffective trial' do
    let(:cracked_ineffective_trial) do
      CourtDataAdaptor::Resource::CrackedIneffectiveTrial
        .new(id: 'a-uuid',
             description: 'Reason for cracked, vacated or ineffective trial')
    end

    context 'with a case level result' do
      context 'with cracked type' do
        before do
          allow(cracked_ineffective_trial).to receive(:type).and_return('Cracked')
        end

        it_behaves_like 'cracked_ineffective_trial with case level result', type_text: 'Cracked'
      end

      context 'with vacated type and code indicating a crack' do
        before do
          allow(cracked_ineffective_trial).to receive_messages(type: 'Vacated', code: 'A')
        end

        it_behaves_like 'cracked_ineffective_trial with case level result', type_text: 'Vacated'
      end
    end

    context 'without a case level result' do
      before do
        allow(cracked_ineffective_trial).to receive_messages(type: 'Ineffective')
      end

      it 'does not display case result section' do
        render_partial
        expect(rendered).not_to have_content('Case results')
      end
    end
  end

  context 'when no hearing has a cracked ineffective trial' do
    let(:cracked_ineffective_trial) { nil }

    it 'does not display case result section' do
      render_partial
      expect(rendered).not_to have_content('Case results')
    end
  end

  # TODO: since cracks can relate to a specific defendant it is possible
  # , albeit unlikely (1% of cases have 2+ defendants??!), that there could be multiple
  # case level cracks.
  # In such cases the view should be adding a row to the same table, not creating
  # a new table. Duplication could also become an issue??!
  #
  # context 'when there are multiple cracked ineefective trials' do
  # end
end
