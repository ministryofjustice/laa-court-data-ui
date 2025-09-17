# frozen_string_literal: true

RSpec.feature 'Unlinking a defendant from MAAT', :stub_unlink, type: :feature do
  let(:case_urn) { 'TEST12345' }
  let(:api_url_v2) { Cda::BaseModel.api_url }
  let(:api_request_path) { "#{api_url_v2}/laa_references/#{defendant_id}" }

  let(:user) { create(:user) }

  before do
    sign_in user

    create(:unlink_reason,
           code: 1,
           description: 'Linked to wrong case ID (correct defendant)',
           text_required: false)
    create(:unlink_reason, code: 7, description: 'Other', text_required: true)

    visit(url)
  end

  context 'when user views unlinked defendant' do
    let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
    let(:url) { "laa_references/#{defendant_id}/link_form?urn=#{case_urn}" }

    it 'displays the MAAT ID field' do
      expect(page).to have_field('MAAT ID')
    end

    it 'displays the MAAT ID field hint' do
      expect(page).to have_content('Enter the MAAT ID')
    end

    it 'does not display the Remove link' do
      expect(page).to have_no_text('Unlink MAAT ID')
    end
  end

  context 'when user views linked defendant' do
    let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
    let(:url) { "defendants/#{defendant_id}/edit?urn=#{case_urn}" }
    let(:maat_reference) { 2_123_456.to_s }

    it 'does not display the MAAT ID field' do
      expect(page).to have_no_field('MAAT ID')
    end

    it 'does not display the MAAT ID field hint' do
      expect(page).to have_no_content('Enter the MAAT ID')
    end

    it 'displays the remove link detail' do
      expect(page).to have_text('Unlink MAAT ID')
    end

    it 'displays the remove link warning' do
      click_link 'Unlink MAAT ID'
      expect(page).to have_govuk_warning('Removing the link will stop hearing updates being received')
    end

    context 'when user unlinks with success' do
      let(:api_request_payload) do
        {
          laa_reference: { defendant_id:,
                           user_name: user.username,
                           unlink_reason_code: 1,
                           maat_reference: }
        }
      end

      context 'with standard reason' do
        before do
          click_link 'Unlink MAAT ID'
          select 'Linked to wrong case ID (correct defendant)', from: 'Reason for unlinking'
          click_button 'Remove link to court data'
        end

        it 'sends an unlink request to CD API' do
          expect(a_request(:patch, api_request_path)
            .with(body: api_request_payload))
            .to have_been_made
        end

        it 'flashes notice' do
          expect(page).to \
            have_govuk_flash(:success, text: 'You removed the link to MAAT ID 2123456')
        end
      end

      context 'with other reason' do
        let(:api_request_payload) do
          {
            laa_reference: { defendant_id:,
                             user_name: user.username,
                             unlink_reason_code: 7,
                             maat_reference:,
                             unlink_other_reason_text: 'Case already concluded' }
          }
        end

        before do
          click_link 'Unlink MAAT ID'
          select 'Other', from: 'Reason for unlinking'
          fill_in 'Other reason', with: 'Case already concluded'
          click_link_or_button 'Remove link to court data'
        end

        it 'sends an unlink request to CD API' do
          expect(a_request(:patch, api_request_path)
            .with(body: api_request_payload.to_json))
            .to have_been_made
        end

        it 'flashes notice' do
          expect(page).to \
            have_govuk_flash(:success, text: 'You removed the link to MAAT ID 2123456')
        end
      end
    end

    context 'when user unlinks defendant with failure' do
      before do
        click_link 'Unlink MAAT ID'
        select 'Linked to wrong case ID (correct defendant)', from: 'Reason for unlinking'
        click_link_or_button 'Remove link to court data'
      end

      it 'flashes alert for 422 Unprocessable Content response', :stub_v2_unlink_bad_response do
        expect(page).to \
          have_govuk_flash(
            :alert,
            text: 'The request to link/unlink the Defendant or Appellant was malformed.'
          )
      end

      it 'flashes alert if there is a CDA failure', :stub_v2_unlink_cda_failure do
        expect(page).to \
          have_govuk_flash(
            :alert,
            text: 'HMCTS Common Platform could not be reached.'
          )
      end
    end
  end
end
