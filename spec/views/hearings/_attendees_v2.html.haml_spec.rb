# frozen_string_literal: true

RSpec.describe 'hearings/_attendees_v2.html.haml', type: :view do
  include RSpecHtmlMatchers
  subject(:render_partial) { render partial: 'attendees_v2', locals: { hearing: } }

  let(:hearing_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:hearing_day) { Date.parse('2019-10-23T10:30:00.000Z') }
  let(:hearing) { CdApi::Hearing.find(hearing_id, params: { date: hearing_day.strftime('%F') }) }

  context 'when hearing data is present', stub_v2_hearing_data: true do
    it 'displays the section' do
      is_expected.to have_tag('h2.govuk-heading-l', text: /Attendees/)
    end

    context 'with defendant_names' do
      it 'displays the defendants section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Defendants/)
      end

      it 'displays defendant names with line breaks' do
        is_expected.to have_tag('p.govuk-body#defendants', text: /Leon Goodwin.*David Blaine/) do
          with_tag(:br)
        end
      end
    end

    context 'with defence_counsel' do
      it 'displays the defence section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Defence advocates/)
      end

      it 'displays list of defence council' do
        is_expected.to have_tag('p.govuk-body#defence',
                                text: /mark jones \(junior\).*david williams \(junior\)/)
      end
    end

    context 'with prosecution_counsel' do
      it 'displays the prosecution section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Prosecution advocates/)
      end

      it 'displays list of prosecution counsel' do
        is_expected.to have_tag('p.govuk-body#prosecution', text: /john smith/)
      end
    end

    context 'with judiciaries' do
      it 'displays the judges section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Judges/)
      end

      it 'displays list of judges' do
        is_expected.to have_tag('p.govuk-body#judges',
                                text: /Miss Antigoni Efstathiou.*Mrs Janette Felicity Ackerley/)
      end
    end
  end

  context 'when no hearing data is present', stub_v2_empty_hearing_data: true do
    it 'displays the section' do
      is_expected.to have_tag('h2.govuk-heading-l', text: /Attendees/)
    end

    context 'with no defendant_names' do
      it 'displays the defendants section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Defendants/)
      end

      it 'displays not available' do
        is_expected.to have_tag('p.govuk-body#defendants', text: /Not available/)
      end
    end

    context 'with no defence_counsel' do
      it 'displays the defence section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Defence advocates/)
      end

      it 'displays not available' do
        is_expected.to have_tag('p.govuk-body#defence', text: /Not available/)
      end
    end

    context 'with no prosecution_counsel' do
      it 'displays the prosecution section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Prosecution advocates/)
      end

      it 'displays not available' do
        is_expected.to have_tag('p.govuk-body#prosecution', text: /Not available/)
      end
    end

    context 'with no judiciaries' do
      it 'displays the judges section' do
        is_expected.to have_tag('div.govuk-heading-s', text: /Judges/)
      end

      it 'displays not available' do
        is_expected.to have_tag('p.govuk-body#judges', text: /Not available/)
      end
    end
  end
end
