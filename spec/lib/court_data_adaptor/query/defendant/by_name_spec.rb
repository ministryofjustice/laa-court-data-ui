# frozen_string_literal: true

require 'court_data_adaptor'

RSpec.describe CourtDataAdaptor::Query::Defendant::ByName do
  subject { described_class }

  let(:instance) { described_class.new(nil) }
  let(:term) { 'GLove' }
  let(:dob) { Date.parse('01-01-1990') }

  def self.resource
    CourtDataAdaptor::Resource::ProsecutionCase
  end

  it_behaves_like('court_data_adaptor acts_as_resource object', resource:) do
    let(:klass) { described_class }
    let(:instance) { described_class.new(nil) }
  end

  it_behaves_like 'court_data_adaptor query object'

  it { expect(instance).to respond_to(:dob, :dob=) }

  describe '#call' do
    subject(:call) { instance.call }

    let(:instance) { described_class.new(term, dob:) }

    context 'with mocking' do
      let(:resource) { self.class.resource }
      let(:resultset) { instance_double('ResultSet') } # rubocop:disable RSpec/StringAsInstanceDoubleConstant

      before do
        allow(instance).to receive(:refresh_token_if_required!)
        allow(resource).to receive(:includes).with(:defendants).and_return(resultset)
        allow(resultset).to receive_messages(where: resultset, all: resultset, each_with_object: Array)
        call
      end

      it 'refreshes access_token if required' do
        expect(instance).to have_received(:refresh_token_if_required!)
      end

      it 'sends includes(:defendants) query to resource' do
        expect(resource).to have_received(:includes).with(:defendants)
      end

      it 'sends where query, unaltered, to resource' do
        expect(resultset)
          .to have_received(:where)
          .with(name: 'GLove', date_of_birth: '1990-01-01')
      end

      it 'sends all message to resultset' do
        expect(resultset).to have_received(:all)
      end
    end

    context 'without mocking', :vcr do
      it 'includes name filter in request' do
        call
        expect(
          a_request(:get, %r{.*/api/internal/v1/prosecution_cases\?.*filter\[name\]=GLove.*})
          .with(headers: { 'Content-Type' => 'application/vnd.api+json' })
        ).to have_been_made.once
      end

      it 'includes date_of_birth filter in request' do
        call
        expect(
          a_request(:get, %r{.*/api/internal/v1/prosecution_cases\?.*filter\[date_of_birth\]=1990-01-01.*})
          .with(headers: { 'Content-Type' => 'application/vnd.api+json' })
        ).to have_been_made.once
      end

      # NOTE: common platform appears to use elastic search
      # so this matches names that include EITHER "trever" OR "glover"
      context 'with two term name search', :vcr do
        subject(:results) { instance.call }

        let(:term) { 'trever glover' }

        it 'returns defendant resources' do
          expect(results).to all(be_instance_of(CourtDataAdaptor::Resource::Defendant))
        end

        it 'returns exact name match first' do
          expect(results.first).to have_attributes(name: 'Trever Glover', date_of_birth: '1990-01-01')
        end

        it 'returns defendants with exact matching date_of_birth' do
          expect(results).to all(have_attributes(date_of_birth: '1990-01-01'))
        end

        it 'returns defendants with partial matching names' do
          names = results.map { |res| res.name.downcase }
          expect(names).to all(match('glover')).or all(match('trever'))
        end

        it 'populates prosecution_case_reference attribute' do
          case_refs = results.map(&:prosecution_case_reference)
          expect(case_refs).to be_present.and all(be_present)
        end
      end

      # NOTE: common platform appears to use elastic search
      # so this returns names that include "trever"
      context 'with single term (partial) name search', :vcr do
        subject(:results) { instance.call }

        let(:term) { 'trever' }

        it 'returns defendant resources' do
          expect(results).to all(be_instance_of(CourtDataAdaptor::Resource::Defendant))
        end

        it 'returns defendants with exact date_of_birth' do
          expect(results).to all(have_attributes(date_of_birth: '1990-01-01'))
        end

        it 'returns defendants with partial matching names' do
          names = results.map { |res| res.name.downcase }
          expect(names).to all(match('trever'))
        end

        it 'populates prosecution_case_reference attribute' do
          case_refs = results.map(&:prosecution_case_reference)
          expect(case_refs).to be_present.and all(be_present)
        end
      end
    end
  end
end
