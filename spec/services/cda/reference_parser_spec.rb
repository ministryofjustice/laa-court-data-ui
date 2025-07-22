# frozen_string_literal: true

RSpec.describe Cda::ReferenceParser do
  subject { described_class.new(term) }

  describe '#original_value' do
    subject { described_class.new(term).original_value }

    let(:term) { 'YE 74 44 78 B' }

    it 'returns original term unmodified' do
      is_expected.to eql 'YE 74 44 78 B'
    end
  end

  describe '#value' do
    subject { described_class.new(term).value }

    let(:term) { "\t ye \r 74 / 44  - 78  \n b  " }

    it 'returns term stripped whitespace, symobls and upcased' do
      is_expected.to eql 'YE744478B'
    end
  end

  describe '#kind' do
    subject { described_class.new(term).kind }

    context 'with a national insurance number' do
      let(:term) { "\t ye \r 74 / 44  - 78  \n b  " }

      it { is_expected.to be :national_insurance_number }
    end

    context 'with anything other than national insurance number' do
      let(:term) { 'anything-else' }

      it { is_expected.to be :arrest_summons_number }
    end
  end

  describe '#national_insurance_number?' do
    # HMCTS Mock API valid NI:
    # "(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)(?:[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z])(?:\s*\d\s*){6}([A-D]|\s)$"
    # see https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim39110 for details
    #
    context 'when term is a valid national insurance number' do
      terms = {
        'OA123456A' => 'O is valid for first letter only',
        'AA123456A' => 'suffix A is valid',
        'AA123456B' => 'suffix B is valid',
        'AA123456C' => 'suffix C is valid',
        'AA123456D' => 'suffix D is valid'
      }

      terms.each do |term, message|
        it "#{term} - #{message}" do
          expect(described_class.new(term)).to be_national_insurance_number, "expected #{term} to be considered a valid national insurance number because \"#{message}\""
        end
      end
    end

    context 'when term is NOT a valid national insurance number' do
      terms = {
        '123456D' => 'must have 2 letter prefix',
        'AA123456' => 'must have 1 letter suffix',
        'A123456D' => 'prefix must be 2 letters exactly',
        'AAA123456D' => 'prefix must be 2 letters exactly',
        'AA1234567D' => 'must have exactly 6 digits',
        'AA12345D' => 'must have exactly 6 digits',
        'VA123456D' => 'D, F, I, Q, U, and V are invalid for prefix',
        'BG123456D' => 'BG is invalid prefix',
        'GB123456D' => 'GB is invalid prefix',
        'KN123456D' => 'KN is invalid prefix',
        'NK123456D' => 'NK is invalid prefix',
        'NT123456D' => 'NT is invalid prefix',
        'TN123456D' => 'TN is invalid prefix',
        'ZZ123456D' => 'ZZ is invalid prefix',
        'AO123456D' => 'O is invalid for second letter of prefix',
        'AA123456E' => 'E-Z is invalid suffix'
      }

      terms.each do |term, message|
        it "#{term} - #{message}" do
          expect(described_class.new(term)).not_to be_national_insurance_number, "expected #{term} to be considered an invalid national insurance number because\"#{message}\""
        end
      end
    end
  end

  # Arrest summons number (ASN) format?? Criminal prosecution reference (CPR)
  # https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/360582/cjs-data-standards-catalogue-5.0.pdf
  # YYFFFUUSSN(11)A
  # YY - 2 digit year
  # FFFUUSS - Organisation Unit Identifier
  # N(11) - 11 digits (zero left padded) - sequence iterated by year and organizational unit
  # A - check character generated using a specified check character algorithm
  # e.g.
  # 1. 93105CE0101245932H or for display 93/105CE/01/01245932H
  # 2. 93/52HQ/01/123456N or for display 93/52HQ/01/123456N
  #
end
