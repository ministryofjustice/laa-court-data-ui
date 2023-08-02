# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe DefendantHelper, type: :helper do
  describe '#defendant_link_path' do
    let(:prosecution_case_reference) { 'TEST12345' }
    let(:defendant_class) { CourtDataAdaptor::Resource::Defendant }
    # rubocop:disable RSpec/VerifiedDoubles
    let(:defendant) { double(defendant_class) }
    # rubocop:enable RSpec/VerifiedDoubles
    let(:id) { '12abc3de-456f-789g-012h-3456i78jk90l' }

    context 'with URN specified' do
      subject { helper.defendant_link_path(defendant, prosecution_case_reference) }

      context 'when defendant linked' do
        before do
          allow(defendant).to receive_messages(linked?: true, id:)
        end

        it { is_expected.to eql "/defendants/#{id}/edit?urn=#{prosecution_case_reference}" }
      end

      context 'when defendant not linked' do
        before do
          allow(defendant).to receive_messages(linked?: false, id:)
        end

        it { is_expected.to eql "/laa_references/new?id=#{id}&urn=#{prosecution_case_reference}" }
      end
    end

    context 'without URN specified' do
      subject { helper.defendant_link_path(defendant) }

      before do
        allow(defendant).to receive_messages(linked?: true, id:)
      end

      it { is_expected.to eql "/defendants/#{id}/edit" }
    end
  end
end
