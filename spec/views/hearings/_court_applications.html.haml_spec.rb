# frozen_string_literal: true

RSpec.describe 'hearings/_court_applications.html.haml', type: :view do
  subject(:render_partial) { render partial: 'court_applications', locals: { hearing: decorated_hearing } }

  include RSpecHtmlMatchers

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }
  let(:decorated_hearing) { view.decorate(hearing) }
  let(:court_applications) { [court_application1, court_application2] }
  let(:court_application1) { court_application_class.new(received_date: '2021-03-09') }
  let(:court_application2) { court_application_class.new(received_date: '2021-05-10') }
  let(:decorated_court_application) { view.decorate(court_application) }
  let(:court_application_type1) do
    court_application_type_class.new(description: 'Application for transfer of legal aid',
                                     code: 'LA12505',
                                     legislation: 'Pursuant to Regulation 14 of the Criminal Legal Aid',
                                     applicant_appellant_flag: 'false')
  end
  let(:court_application_type2) do
    court_application_type_class.new(description: 'Application for case to be dismissed',
                                     code: 'CD12504',
                                     legislation: 'Pursuant to Regulation 17 of the Courts Act',
                                     applicant_appellant_flag: 'false')
  end
  let(:court_application_class) { CourtDataAdaptor::Resource::CourtApplication }
  let(:court_application_type_class) { CourtDataAdaptor::Resource::CourtApplicationType }

  before do
    allow(hearing).to receive(:court_applications).and_return(court_applications)
    allow(court_application1).to receive(:type).and_return(court_application_type1)
    allow(court_application2).to receive(:type).and_return(court_application_type2)
  end

  it { is_expected.to have_selector('.govuk-heading-m', text: 'Applications') }

  context 'with no court applications' do
    let(:court_applications) { nil }

    it 'does not render content' do
      render_partial
      expect(rendered).to be_blank
    end
  end

  context 'with court applications' do
    it 'displays court applications section once' do
      render_partial
      expect(rendered).to have_css('.govuk-heading-m', text: /Court Applications/).once
    end

    it 'displays all "court applications"' do
      render_partial
      expect(rendered).to have_tag('td.govuk-table__cell') do
        with_text(/Application for transfer of legal aid/)
        with_text(/Application for case to be dismissed/)
      end
    end

    context 'with respondents' do
      let(:respondents) { [respondent1, respondent2] }
      let(:respondent1) { CourtDataAdaptor::Resource::CourtApplicationParty.new(synonym: 'Defendant') }
      let(:respondent2) { CourtDataAdaptor::Resource::CourtApplicationParty.new(synonym: 'Suspect') }

      before { allow(court_application1).to receive(:respondents).and_return(respondents) }

      it 'displays respondent_synonyms with line breaks' do
        is_expected.to have_tag('td.govuk-table__cell', text: /Defendant.*Suspect/) do
          with_tag(:br)
        end
      end
    end

    context 'with no applicant synonym' do
      it 'displays the synonym "Applicant"' do
        is_expected.not_to have_tag('td.govuk-table__cell', text: /Applicant/)
      end
    end

    context 'with an applicant synonym' do
      before { allow(court_application_type1).to receive(:applicant_appellant_flag).and_return(true) }

      it 'displays the synonym "Applicant"' do
        is_expected.to have_tag('td.govuk-table__cell', text: /Applicant/)
      end
    end

    context 'with judicial results' do
      let(:judicial_results) { [judicial_result1, judicial_result2] }
      let(:judicial_result1) do
        judicial_result_class.new(cjs_code: '4600', text: 'Legal Aid Transfer Granted')
      end
      let(:judicial_result2) do
        judicial_result_class.new(cjs_code: '4601', text: 'Legal Aid Transfer Denied')
      end
      let(:judicial_result_class) { CourtDataAdaptor::Resource::JudicialResult }

      before { allow(court_application1).to receive(:judicial_results).and_return(judicial_results) }

      it 'displays both result codes' do
        render_partial
        expect(rendered).to have_tag('td.govuk-table__cell') do
          with_text(/4600/)
          with_text(/4601/)
        end
      end

      it 'displays both result texts' do
        render_partial
        expect(rendered).to have_tag('td.govuk-table__cell') do
          with_text(/Legal Aid Transfer Granted/)
          with_text(/Legal Aid Transfer Denied/)
        end
      end

      context 'with result text containing html, unicode and crlf_escape_sequences' do
        let(:judicial_result1) do
          judicial_result_class.new(cjs_code: '4600', text: free_text)
        end

        include_examples 'free text fields'
      end
    end

    context 'with no judicial results' do
      it 'displays not available for result code and result text' do
        render_partial
        expect(rendered).to have_css('td.govuk-table__cell', text: /Not available/).twice
      end
    end
  end
end
