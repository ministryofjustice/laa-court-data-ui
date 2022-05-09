# frozen_string_literal: true

RSpec.describe 'defendants/_offences_v2.html.haml', type: :view do
  include RSpecHtmlMatchers
  subject(:render_partial) { render partial: 'offences_v2' }

  let(:defendant_id) { '844a6542-ffcb-4cd0-94ce-fda3ffc3081b' }
  let(:case_urn) { 'TEST12345' }
  let(:defendant) { CdApi::Defendant.find(:all, params: { uuid: defendant_id, urn: case_urn }).first }

  context 'when the defendant has an offence', stub_defendants_uuid_urn_search: true do
    before do
      assign(:defendant, defendant)
    end

    context 'when the Offence is empty' do
      it 'displays the header' do
        is_expected.to have_tag('th.govuk-table__header', text: 'Offence and legislation')
      end
    end

    context 'when the plea is empty' do
      it 'displays the header' do
        is_expected.to have_tag('th.govuk-table__header', text: 'Plea')
      end
    end

    context 'when the Mode of Trial is empty' do
      it 'displays the header' do
        is_expected.to have_tag('th.govuk-table__header', text: 'Mode of trial')
      end
    end
  end
end

