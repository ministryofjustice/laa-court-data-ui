# frozen_string_literal: true

require 'ostruct'

RSpec.describe 'link_migrated_cases/show_link.html.haml', type: :view do
  let(:defendant_id) { 'def-1' }

  let(:defendant) do
    build(:defendant_summary,
          id: defendant_id,
          first_name: 'Peter',
          middle_name: 'Apple',
          last_name: 'Rabbit',
          date_of_birth: Date.new(1990, 1, 1),
          arrest_summons_number: 'AS123',
          maat_reference: maat_reference,
          national_insurance_number: 'AB123456C')
  end

  let(:migrated_case) do
    build(:link_migrated_case,
          case_urn: 'TEST12345',
          defendant_id: defendant_id,
          committal_date: nil,
          sent_date: Date.new(2024, 3, 1),
          xhibit_case_number: 'X123',
          court_name: 'Southwark',
          process_errors: { 'message' => 'MAAT application not found' })
  end

  let(:hearing_day) { Date.new(2024, 3, 1) }
  let(:prosecution_case) { double(sorted_hearing_summaries_with_day: [double(day: hearing_day)]) }
  let(:offence_history_collection) { [] }
  let(:form_model) { LinkAttempt.new(defendant_id: defendant_id, username: 'tester') }

  before do
    assign(:defendant, defendant)
    assign(:migrated_case, migrated_case)
    assign(:prosecution_case, prosecution_case)
    assign(:offence_history_collection, offence_history_collection)
    assign(:form_model, form_model)

    allow(view).to receive(:default_form_builder).and_return(GOVUKDesignSystemFormBuilder::FormBuilder)

    # Helpers used in the view
    allow(view).to receive_messages(service_name: 'LAA',
                                    formatted_process_errors: 'MAAT application not found',
                                    offences_defendant_path: '/offences')

    allow(view).to receive(:render).and_call_original
  end

  shared_examples 'common case details' do
    it 'renders the page heading and case details' do
      render

      expect(rendered).to include('Link court data')

      expect(rendered).to include('<strong class="govuk-tag govuk-tag--blue">Trial</strong>')

      expect(rendered).to include('Name')
      expect(rendered).to include('Peter Apple Rabbit')

      expect(rendered).to include('Date of birth')
      expect(rendered).to include('1 Jan 1990')

      expect(rendered).to include('URN')
      expect(rendered).to include('TEST12345')

      expect(rendered).to include('ASN')
      expect(rendered).to include('AS123')

      expect(rendered).to include('NI number')
      expect(rendered).to include('AB123456C')

      expect(rendered).to include('Committal date')
      expect(rendered).to include('1 Mar 2024')

      expect(rendered).to include('Xhibit reference')
      expect(rendered).to include('X123')

      expect(rendered).to include('Court')
      expect(rendered).to include('Southwark')

      expect(rendered).to include('Latest hearing date')
      expect(rendered).to include('1 Mar 2024')

      expect(rendered).to include('Reason for manual linking')
      expect(rendered).to include('MAAT application not found')
    end
  end

  context 'when defendant has a MAAT reference' do
    let(:maat_reference) { '1234567' }

    it_behaves_like 'common case details'

    it 'shows the MAAT number and does not show the linking form' do
      render

      expect(rendered).to have_css('span#defendant-maat-number', text: '1234567')
      expect(rendered).to have_no_field('link_attempt[maat_reference]')
      expect(rendered).to have_no_button('Link')
    end
  end

  context 'when defendant does not have a MAAT reference' do
    let(:maat_reference) { nil }

    it_behaves_like 'common case details'

    it 'renders the linking form' do
      render

      expect(rendered).to include('MAAT ID')
      expect(rendered).to include('Not linked')

      expect(rendered).to have_css('form')
      expect(rendered).to have_field('link_attempt[maat_reference]')
      expect(rendered).to include('Back to overview')
    end
  end
end
