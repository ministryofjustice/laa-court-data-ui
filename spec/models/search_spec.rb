# frozen_string_literal: true

RSpec.describe Search, type: :model do
  subject { described_class.new }

  it {
    is_expected.to \
      respond_to(:filters, :filter,
                 :term, :term=,
                 :dob, :dob=,
                 :execute, :errors, :valid?)
  }

  describe '.filters' do
    subject(:filters) { described_class.filters }

    it { is_expected.to all(be_a(SearchFilter)) }

    it {
      expect(filters.map(&:id)).to include(:case_reference, :defendant_name, :defendant_reference)
    }
  end

  describe '#filters' do
    subject(:filters) { described_class.new.filters }

    before { allow(described_class).to receive(:filters) }

    it 'calls class method' do
      filters
      expect(described_class).to have_received(:filters)
    end
  end

  describe '#execute' do
    before do
      allow(query_class).to receive(:new).and_return(query_instance)
      allow(query_instance).to receive(:call)
      search_instance.execute
    end

    context 'when searching by case reference', stub_no_results: true do
      subject(:search_instance) { described_class.new(filter: filter, term: term) }

      let(:filter) { 'case_reference' }
      let(:term) { 'case-urn' }
      let(:dob) { Date.parse('21-05-1987') }

      let(:query_class) { CourtDataAdaptor::Query::ProsecutionCase }
      let(:query_instance) { instance_double(query_class) }

      it 'sends term to case reference query object' do
        expect(query_class).to have_received(:new).with(term)
      end

      it 'calls case reference query object' do
        expect(query_instance).to have_received(:call)
      end
    end

    context 'when searching by defendant name', stub_no_results: true do
      subject(:search_instance) { described_class.new(filter: filter, term: term, dob: dob) }

      let(:filter) { 'defendant_name' }
      let(:term) { 'defendant-name' }
      let(:dob) { Date.parse('21-05-1987') }

      let(:query_class) { CourtDataAdaptor::Query::Defendant::ByName }
      let(:query_instance) { instance_double(query_class) }

      it 'sends term and dob to defandant query object' do
        expect(query_class).to have_received(:new).with(term, dob: dob)
      end

      it 'calls defendant query object' do
        expect(query_instance).to have_received(:call)
      end
    end

    context 'when searching by defendant reference', stub_no_results: true do
      subject(:search_instance) { described_class.new(filter: filter, term: term) }

      let(:filter) { 'defendant_reference' }
      let(:term) { 'defendant-ni-number' }

      let(:query_class) { CourtDataAdaptor::Query::Defendant::ByReference }
      let(:query_instance) { instance_double(query_class) }

      it 'sends term to defandant query object' do
        expect(query_class).to have_received(:new).with(term)
      end

      it 'calls defendant query object' do
        expect(query_instance).to have_received(:call)
      end
    end
  end

  context 'when validating' do
    subject(:search) { described_class.new(filter: filter, term: term, dob: dob) }

    context 'with case reference search' do
      let(:filter) { 'case_reference' }
      let(:term) { 'TFL12345' }
      let(:dob) { nil }

      context 'with blank filter' do
        let(:filter) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activerecord_error(:filter, 'Filter required') }
      end

      context 'with not included filter' do
        let(:filter) { 'invalid_filter' }

        it { is_expected.to be_invalid }

        it {
          is_expected.to \
            have_activerecord_error(:filter, 'Filter "invalid_filter" is not recognized')
        }
      end

      context 'with blank term' do
        let(:term) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activerecord_error(:term, 'Search term required') }
      end

      context 'with blank dob' do
        let(:dob) { nil }

        it { is_expected.to be_valid }
      end
    end

    context 'with defendant name search' do
      let(:filter) { 'defendant_name' }
      let(:term) { 'Mickey Mouse' }
      let(:dob) { Date.current }

      context 'with blank filter' do
        let(:filter) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activerecord_error(:filter, 'Filter required') }
      end

      context 'with blank term' do
        let(:term) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activerecord_error(:term, 'Search term required') }
      end

      context 'with blank dob' do
        let(:dob) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activerecord_error(:dob, 'Defendant date of birth required') }
      end
    end

    context 'with defendant reference search' do
      let(:filter) { 'defendant_reference' }
      let(:term) { 'HR669639M' }
      let(:dob) { nil }

      context 'with blank filter' do
        let(:filter) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activerecord_error(:filter, 'Filter required') }
      end

      context 'with blank term' do
        let(:term) { nil }

        it { is_expected.to be_invalid }
        it { is_expected.to have_activerecord_error(:term, 'Search term required') }
      end
    end
  end
end
