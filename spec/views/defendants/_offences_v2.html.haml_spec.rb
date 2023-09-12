# frozen_string_literal: true

RSpec.describe 'defendants/_offences_v2.html.haml', type: :view do
  include RSpecHtmlMatchers
  subject(:render_partial) { render partial: 'defendants/offences_v2', locals: { defendant: } }

  let(:defendant_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:case_urn) { 'TEST12345' }
  let(:defendant) { CdApi::Defendant.find(:all, params: { uuid: defendant_id, urn: case_urn }).first }

  context 'when the defendant has an offence', :stub_defendants_uuid_urn_search do
    before do
      assign(:defendant, defendant)
    end

    context 'when the date is present' do
      it 'displays the header' do
        is_expected.to have_tag('th.govuk-table__header', text: /Date/)
      end

      it 'displays the value' do
        is_expected.to have_tag('td.govuk-table__cell', text: %r{17/10/2019})
      end
    end

    context 'when the Offence is present' do
      it 'displays the header' do
        is_expected.to have_tag('th.govuk-table__header', text: /Offence and legislation/)
      end

      context 'when the offence is null' do
        it 'displays the offense title' do
          is_expected.to have_tag('td.govuk-table__cell', text: /Not available/)
        end
      end

      context 'when the offence has a value' do
        it 'displays the offense title' do
          is_expected.to have_tag('td.govuk-table__cell',
                                  text: /Abuse of trust: sexual activity with a child/) do
            with_tag('span.app-body-secondary', text: /Customs and Excise Management Act 1979 s.50/)
          end
        end
      end
    end

    context 'when the plea is present' do
      it 'displays the header' do
        is_expected.to have_tag('th.govuk-table__header', text: /Plea/)
      end

      context 'when the plea is empty' do
        it 'displays not available' do
          is_expected.to have_tag('td.govuk-table__cell', text: /Not available/)
        end
      end

      context 'when the plea has a value' do
        it 'displays the value' do
          is_expected.to have_tag('td.govuk-table__cell', text: %r{Not guilty on 17/10/2019})
        end
      end
    end

    context 'when the Mode of Trial is empty' do
      it 'displays the header' do
        is_expected.to have_tag('th.govuk-table__header', text: /Mode of trial/)
      end

      context 'when the mode of trial is empty' do
        it 'displays not available' do
          is_expected.to have_tag('td.govuk-table__cell', text: /Not available/)
        end
      end

      context 'when the mode of trial has a value' do
        it 'displays the value' do
          is_expected.to have_tag('td.govuk-table__cell', text: /Either way/)
        end
      end
    end
  end
end
