# frozen_string_literal: true

RSpec.describe 'hearings/_court_applications_v2.html.haml', type: :view do
  include RSpecHtmlMatchers
  subject(:render_partial) { render partial: 'court_applications_v2', locals: { hearing: hearing.hearing } }

  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing) { CdApi::Hearing.find(hearing_id, params: { date: hearing_day.strftime('%F') }) }

  context 'with court_applications present', :stub_v2_hearing_data do
    it 'displays the section' do
      is_expected.to have_tag('h2.govuk-heading-l', text: /Court Applications/)
    end

    it 'displays all applications' do
      is_expected.to have_tag('span.govuk-accordion__section-button',
                              text: /Application for transfer of legal aid/)
    end

    it 'displays received date correctly' do
      is_expected.to have_tag('div.govuk-accordion__section-summary', text: /29 March 2021/)
    end
  end

  context 'with no court_applications present', :stub_v2_empty_hearing_data do
    it 'displays the section' do
      is_expected.to have_tag('h2.govuk-heading-l', text: /Court Applications/)
    end

    it 'displays correct message' do
      is_expected.to have_tag('p.govuk-body',
                              text: /No court applications are associated with this hearing/)
    end
  end
end
