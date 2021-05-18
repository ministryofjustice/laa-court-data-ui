# frozen_string_literal: true

RSpec.describe CourtApplicationDecorator, type: :decorator do
  subject(:decorator) { described_class.new(court_application, view_object) }

  let(:court_application) { instance_double(CourtDataAdaptor::Resource::CourtApplication) }
  let(:view_object) { view_class.new }

  let(:view_class) do
    Class.new do
      include ActionView::Helpers
      include ApplicationHelper
    end
  end

  it_behaves_like 'a base decorator' do
    let(:object) { court_application }
  end

  context 'when method is missing' do
    before { allow(court_application).to receive_messages(received_date: '') }

    it { is_expected.to respond_to(:received_date) }
  end

  describe '#respondent_list' do
    subject(:call) { decorator.respondent_list }

    before { allow(court_application).to receive_messages(respondents: respondents) }

    context 'with multiple respondents' do
      let(:respondents) { [respondent1, respondent2] }
      let(:respondent1) { CourtDataAdaptor::Resource::CourtApplicationParty.new(synonym: 'Defendant') }
      let(:respondent2) { CourtDataAdaptor::Resource::CourtApplicationParty.new(synonym: 'Suspect') }

      it { is_expected.to eql('Defendant<br>Suspect') }
    end

    context 'with no respondents' do
      let(:respondents) { [] }

      it { is_expected.to eql 'Not available' }
    end

    context 'with missing respondent details' do
      let(:respondents) { [respondent1, respondent2] }
      let(:respondent1) { CourtDataAdaptor::Resource::CourtApplicationParty.new(synonym: nil) }
      let(:respondent2) { CourtDataAdaptor::Resource::CourtApplicationParty.new(synonym: 'Defendant') }

      it { is_expected.to eql '<br>Defendant' }
    end
  end

  describe '#applicant_synonym' do
    subject(:call) { decorator.applicant_synonym }

    # rubocop: disable RSpec/VerifiedDoubles
    # NOTE: cannot use instance_double because we are using
    # has_one :court_application_type
    # instead of
    # has_one :type
    # in court_application.rb
    let(:court_application) { double(CourtDataAdaptor::Resource::CourtApplication) }
    let(:type) { instance_double(CourtDataAdaptor::Resource::CourtApplicationType) }
    # rubocop: enable RSpec/VerifiedDoubles

    before { allow(court_application).to receive(:type).and_return(type) }

    context 'with applicant synonym' do
      before do
        allow(type).to receive(:applicant_appellant_flag).and_return(true)
      end

      it { is_expected.to eql 'Applicant' }
    end

    context 'with no applicant synonym' do
      before do
        allow(type).to receive(:applicant_appellant_flag).and_return(false)
      end

      it { is_expected.to eql '' }
    end
  end
end
