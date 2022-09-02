# frozen_string_literal: true

RSpec.describe 'hearings/_attendees_v2', type: :view do
  include RSpecHtmlMatchers
  subject(:render_partial) do
    render partial: 'hearings/attendees_v2',
           locals: { hearing: decorated_hearing, hearing_details: decorated_hearing.hearing }
  end

  let(:decorated_hearing) { view.decorate(hearing, CdApi::HearingDecorator) }
  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing) { CdApi::Hearing.find(hearing_id, params: { date: hearing_day.strftime('%F') }) }

  not_available_text = /Not available/
  not_available_test = 'displays not available'
  small_gov_heading = 'div.govuk-heading-s'

  shared_examples 'returns correct headers' do
    it 'displays the section' do
      is_expected.to have_tag('h2.govuk-heading-l', text: /Attendees/)
    end

    it 'displays the defendants section' do
      is_expected.to have_tag(small_gov_heading, text: /Defendants/)
    end

    it 'displays the defence section' do
      is_expected.to have_tag(small_gov_heading, text: /Defence advocates/)
    end

    it 'displays the prosecution section' do
      is_expected.to have_tag(small_gov_heading, text: /Prosecution advocates/)
    end

    it 'displays the judges section' do
      is_expected.to have_tag(small_gov_heading, text: /Judges/)
    end
  end

  context 'when hearing data is present', stub_v2_hearing_data: true do
    include_examples 'returns correct headers'

    context 'with defendant_names' do
      it 'displays defendant names with line breaks' do
        is_expected.to have_tag('p.govuk-body#defendants', text: /Leon Goodwin.*David Blaine/) do
          with_tag(:br)
        end
      end
    end

    context 'with defence_counsel' do
      before do
        allow(decorated_hearing).to receive(:current_sitting_day).and_return('2019-10-23')
      end

      it 'displays list of defence council' do
        text_match = /Mark Jones \(junior\) for Leon Goodwin.*David Williams \(junior\) for not available/
        is_expected.to have_tag('p.govuk-body#defence',
                                text: text_match)
      end
    end

    context 'when defence counsel did not attend' do
      let(:unattended_day) { '2099-10-23' }

      before do
        allow(decorated_hearing).to receive(:current_sitting_day).and_return(unattended_day)
      end

      it 'displays list of defence council' do
        text_match = /Mark Jones \(junior\) for Leon Goodwin.*David Williams \(junior\) for not available/
        is_expected.not_to have_tag('p.govuk-body#defence', text: text_match)
      end
    end

    context 'with prosecution_counsel' do
      it 'displays list of prosecution counsel' do
        is_expected.to have_tag('p.govuk-body#prosecution', text: /john smith/)
      end
    end

    context 'with judiciaries' do
      it 'displays list of judges' do
        is_expected.to have_tag('p.govuk-body#judges',
                                text: /Miss Antigoni Efstathiou.*Mrs Janette Felicity Ackerley/)
      end
    end
  end

  context 'when no hearing data is present', stub_v2_empty_hearing_data: true do
    context 'with no defendant_names' do
      it not_available_test do
        is_expected.to have_tag('p.govuk-body#defendants', text: not_available_text)
      end
    end

    context 'with no defence_counsel' do
      it not_available_test do
        is_expected.to have_tag('p.govuk-body#defence', text: not_available_text)
      end
    end

    context 'with no prosecution_counsel' do
      it not_available_test do
        is_expected.to have_tag('p.govuk-body#prosecution', text: not_available_text)
      end
    end

    context 'with no judiciaries' do
      it not_available_test do
        is_expected.to have_tag('p.govuk-body#judges', text: not_available_text)
      end
    end
  end
end
