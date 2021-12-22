# frozen_string_literal: true

# See https://jsonapi.org/format/#document-resource-object-attributes
#
# Complex data structures involving JSON objects and arrays are allowed
# as attribute values. However, any object that constitutes or is
# contained in an attribute MUST NOT contain a relationships or links
# member, as those members are reserved by this specification for future use.
#
require 'court_data_adaptor/caster/pleas_collection'

RSpec.describe CourtDataAdaptor::Caster::PleasCollection do
  describe '.cast' do
    subject(:collection) { described_class.cast(value, default) }

    let(:array_of_hashes) do
      [{ code: 'code1',
         pleaded_at: 'pleaded_at1',
         originating_hearing_id: 'id1' },
       { code: 'code2',
         pleaded_at: 'pleaded_at2',
         originating_hearing_id: 'id2' }]
    end

    context 'with an array of hashes' do
      let(:value) { array_of_hashes }
      let(:default) { [] }

      it { is_expected.to all(be_an(CourtDataAdaptor::Resource::Plea)) }

      it 'responds to key names as attributes' do
        expect(collection).to all(respond_to(:code, :pleaded_at, :originating_hearing_id))
      end
    end

    context 'without default' do
      subject(:collection) { described_class.cast(nil) }

      it { is_expected.to be_an Array }
      it { is_expected.to be_empty }
    end

    context 'with empty default' do
      subject(:collection) { described_class.cast(nil, []) }

      it { is_expected.to be_an Array }
      it { is_expected.to be_empty }
    end

    context 'with default' do
      let(:value) { nil }
      let(:default) { [{ code: 'default', description: 'default', originating_hearing_id: 'default' }] }

      it { is_expected.to be_an Array }
      it { is_expected.to all(be_an(CourtDataAdaptor::Resource::Plea)) }

      it 'responds to key names as attributes' do
        expect(collection).to all(respond_to(:code, :pleaded_at, :originating_hearing_id))
      end
    end
  end
end
