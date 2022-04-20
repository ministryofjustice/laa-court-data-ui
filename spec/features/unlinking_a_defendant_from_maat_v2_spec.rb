# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.feature 'Unlinking a defendant from MAAT', type: :feature do
  let(:defendant_nino_from_fixture) { 'JC123456A' }
  let(:case_reference_from_fixture) { 'TEST12345' }

  let(:user) { create(:user) }

  before do
    ENV['LAA_REFERENCES'] = 'true'
    sign_in user

    create(:unlink_reason,
           code: 1,
           description: 'Linked to wrong case ID (correct defendant)',
           text_required: false)
    create(:unlink_reason, code: 7, description: 'Other', text_required: true)

    query = hash_including({ filter: { national_insurance_number: defendant_nino_from_fixture } })
    body = load_json_stub(defendant_fixture)
    defendant_body = load_json_stub(defendant_by_id_fixture)
    json_api_header = { 'Content-Type' => 'application/vnd.api+json' }

    stub_request(:get, "#{api_url}/prosecution_cases")
      .with(query:)
      .to_return(body:, headers: json_api_header)

    stub_request(:get, "#{api_url}/defendants/#{defendant_id}?include=offences")
      .to_return(body: defendant_body, headers: json_api_header)

    visit(url)
  end

  context 'when user views unlinked defendant' do
    let(:defendant_fixture) { 'unlinked/defendant_by_reference_body.json' }
    let(:defendant_by_id_fixture) { 'unlinked_defendant.json' }
    let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
    let(:url) { "laa_references/new?id=#{defendant_id}&urn=#{case_reference_from_fixture}" }

    it 'displays the MAAT ID field' do
      expect(page).to have_field('MAAT ID')
    end

    it 'displays the MAAT ID field hint' do
      expect(page).to have_content('Enter the MAAT ID')
    end

    it 'does not display the Remove link' do
      expect(page).not_to have_govuk_detail_summary('Remove link to court data')
    end

    it 'does not display the remove MAAT ID warning' do
      expect(page).not_to have_govuk_warning('Removing the link will stop hearing updates being received')
    end
  end

  context 'when user views linked defendant' do
    let(:defendant_fixture) { 'linked/defendant_by_reference_body.json' }
    let(:defendant_by_id_fixture) { 'linked_defendant.json' }
    let(:defendant_id) { '41fcb1cd-516e-438e-887a-5987d92ef90f' }
    let(:url) { "defendants/#{defendant_id}/edit?urn=#{case_reference_from_fixture}" }
    let(:adaptor_request_path) { "#{api_url}/defendants/#{defendant_id}" }
    let(:maat_reference) { 2_123_456 }
    let(:api_url_v2) { BaseModel.site }
    let(:api_request_path) { "#{api_url_v2}/laa_references/#{defendant_id}/" }

    it 'does not display the MAAT ID field' do
      expect(page).not_to have_field('MAAT ID')
    end

    it 'does not display the MAAT ID field hint' do
      expect(page).not_to have_content('Enter the MAAT ID')
    end

    it 'displays the remove link detail' do
      expect(page).to have_govuk_detail_summary('Remove link to court data')
    end

    it 'displays the remove link warning' do
      expect(page).to have_govuk_warning('Removing the link will stop hearing updates being received')
    end

    context 'when user unlinks with success' do
      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(
            status: 202,
            body: '',
            headers: { 'Content-Type' => 'text/plain; charset=utf-8' }
          )
      end

      let(:adaptor_request_payload) do
        {
          data:
          {
            id: defendant_id,
            type: 'defendants',
            attributes: {
              defendant_id:,
              user_name: user.username,
              unlink_reason_code: 1
            }
          }
        }
      end

      let(:api_request_payload) do
        {
          defendant_id:,
          user_name: user.username,
          unlink_reason_code: 1,
          maat_reference: maat_reference,
        }
      end

      context 'with standard reason' do
        before do
          click_govuk_detail_summary 'Remove link to court data'
          select 'Linked to wrong case ID (correct defendant)', from: 'Reason for unlinking'
          click_button 'Remove link to court data'
        end

        it 'sends an unlink request to JSON API Client' do
          expect(a_request(:patch, adaptor_request_path)
            .with(body: adaptor_request_payload.to_json))
            .to have_been_made
        end

        it 'sends an unlink request to CD API' do
          expect(a_request(:patch, api_request_path)
            .with(body: api_request_payload.to_json))
            .to have_been_made
        end

        it 'flashes notice' do
          expect(page).to \
            have_govuk_flash(:notice, text: 'You have successfully unlinked from the court data source')
        end
      end

      context 'with other reason' do
        let(:adaptor_request_payload) do
          {
            data:
            {
              id: defendant_id,
              type: 'defendants',
              attributes: {
                defendant_id:,
                user_name: user.username,
                unlink_reason_code: 7,
                unlink_other_reason_text: 'Case already concluded'
              }
            }
          }
        end

        let(:api_request_payload) do
          {
            defendant_id:,
            user_name: user.username,
            unlink_reason_code: 7,
            maat_reference: maat_reference,
            unlink_other_reason_text: 'Case already concluded',
          }
        end

        before do
          click_govuk_detail_summary 'Remove link to court data'
          select 'Other', from: 'Reason for unlinking'
          fill_in 'Other reason', with: 'Case already concluded'
          click_button 'Remove link to court data'
        end

        it 'sends an unlink request to JSON API Client' do
          expect(a_request(:patch, adaptor_request_path)
            .with(body: adaptor_request_payload.to_json))
            .to have_been_made
        end

        it 'sends an unlink request to CD API' do
          expect(a_request(:patch, api_request_path)
            .with(body: api_request_payload.to_json))
            .to have_been_made
        end

        it 'flashes notice' do
          expect(page).to \
            have_govuk_flash(:notice, text: 'You have successfully unlinked from the court data source')
        end
      end
    end

    context 'when user unlinks defendant with failure' do
      before do
        stub_request(:patch, adaptor_request_path)
          .to_return(
            status: 400,
            body: '{"user_name":["must not exceed 10 characters"]}',
            headers: { 'Content-Type' => 'application/vnd.api+json; charset=utf-8' }
          )

        click_govuk_detail_summary 'Remove link to court data'
        select 'Linked to wrong case ID (correct defendant)', from: 'Reason for unlinking'
        click_button 'Remove link to court data'
      end

      it 'flashes alert' do
        expect(page).to \
          have_govuk_flash(
            :alert,
            text: /The link to the court data source could not be removed\./
          )
      end

      it 'flashes returned error' do
        expect(page).to \
          have_govuk_flash(
            :alert,
            text: /User name must not exceed 10 characters/
          )
      end
    end
  end
end
