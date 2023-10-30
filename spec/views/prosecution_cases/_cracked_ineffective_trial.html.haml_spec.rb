# frozen_string_literal: true

RSpec.shared_examples 'cracked_ineffective_trial with case level result' do |options|
  include RSpecHtmlMatchers

  let(:type_text) { options.fetch(:type_text) }

  it 'displays case result section' do
    render_partial
    expect(rendered).to have_css('th.govuk-table__header', text: /Case results/)
  end

  it 'displays the cracked_ineffective_trial type' do
    render_partial
    expect(rendered).to have_css('td.govuk-table__cell', text: /#{type_text}/)
  end

  it 'displays reason' do
    render_partial
    expect(rendered).to have_css('td.govuk-table__cell',
                                 text: /Reason for cracked, vacated or ineffective trial/)
  end
end

RSpec.describe 'prosecution_cases/_cracked_ineffective_trial.html.haml', type: :view do
  subject(:render_partial) do
    render partial: 'cracked_ineffective_trial', locals: { prosecution_case: decorated_prosecution_case }
  end

  include RSpecHtmlMatchers

  let(:decorated_prosecution_case) { view.decorate(prosecution_case) }
  let(:prosecution_case) do
    CourtDataAdaptor::Resource::ProsecutionCase.new(prosecution_case_reference: 'THECASEURN')
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

        it_behaves_like 'cracked_ineffective_trial with case level result', type_text: 'Cracked on 15/01/2021'
      end

      context 'with vacated type and code indicating a crack' do
        before do
          allow(cracked_ineffective_trial).to receive_messages(type: 'Vacated', code: 'A')
        end

        it_behaves_like 'cracked_ineffective_trial with case level result', type_text: 'Vacated on 15/01/2021'
      end
    end

    context 'without a case level result' do
      before do
        allow(cracked_ineffective_trial).to receive_messages(type: 'Ineffective')
      end

      it 'does not render content' do
        render_partial
        expect(rendered).to be_blank
      end
    end
  end

  context 'with no hearings with a cracked ineffective trial' do
    let(:cracked_ineffective_trial) { nil }

    it 'does not render content' do
      render_partial
      expect(rendered).to be_blank
    end
  end

  context 'with multiple cracked ineffective trials' do
    let(:hearings) { [hearing, hearing1, hearing2] }

    let(:hearing1) do
      CourtDataAdaptor::Resource::Hearing
        .new(id: 'the-hearing-uuid',
             hearing_days: ['2021-01-16T13:19:15.000Z'])
    end

    let(:hearing2) do
      CourtDataAdaptor::Resource::Hearing
        .new(id: 'the-hearing-uuid',
             hearing_days: ['2021-01-17T13:19:15.000Z'])
    end

    let(:cracked_ineffective_trial) do
      CourtDataAdaptor::Resource::CrackedIneffectiveTrial
        .new(id: 'ineffective-uuid',
             type: 'Ineffective',
             code: 'M1',
             description: 'Reason for ineffective')
    end

    let(:cracked_ineffective_trial1) do
      CourtDataAdaptor::Resource::CrackedIneffectiveTrial
        .new(id: 'vacated-uuid',
             type: 'Vacated',
             code: 'A',
             description: 'Reason for vacated crack')
    end

    let(:cracked_ineffective_trial2) do
      CourtDataAdaptor::Resource::CrackedIneffectiveTrial
        .new(id: 'cracked-uuid',
             type: 'Cracked',
             code: 'A',
             description: 'Reasons for cracked crack')
    end

    before do
      allow(prosecution_case).to receive(:hearings).and_return(hearings)
      allow(hearing1).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial1)
      allow(hearing2).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial2)
    end

    it 'displays case result section once' do
      render_partial
      expect(rendered).to have_css('th.govuk-table__header', text: /Case results/).once
    end

    it 'displays all "cracks"' do
      render_partial
      expect(rendered).to have_selector('td.govuk-table__cell', text: /Vacated on/)
      expect(rendered).to have_selector('td.govuk-table__cell', text: /Cracked on/)
    end

    it 'does not display "non-cracks"' do
      render_partial
      expect(rendered).not_to have_selector('td.govuk-table__cell', text: /Ineffective/)
    end
  end

  context 'with mixture of hearings with and without cracked ineffective trials' do
    let(:hearings) { [hearing, hearing1] }

    let(:hearing1) do
      CourtDataAdaptor::Resource::Hearing
        .new(id: 'the-hearing-uuid',
             hearing_days: ['2021-01-16T13:19:15.000Z'])
    end

    let(:cracked_ineffective_trial) { nil }

    let(:cracked_ineffective_trial1) do
      CourtDataAdaptor::Resource::CrackedIneffectiveTrial
        .new(id: 'cracked-uuid',
             type: 'Cracked',
             code: 'A',
             description: 'Reasons for cracked crack')
    end

    before do
      allow(hearing1).to receive(:cracked_ineffective_trial).and_return(cracked_ineffective_trial1)
    end

    it 'renders content' do
      render_partial
      expect(rendered).to be_present
    end
  end
end
