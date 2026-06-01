# frozen_string_literal: true

RSpec.describe PaginationHelper, type: :helper do
  describe '#mobile_pagination_series' do
    subject(:series) { helper.mobile_pagination_series(pagy) }

    let(:pagy) { instance_double(Pagy, page: current_page, last: last_page) }

    context 'when on first page of many' do
      let(:current_page) { 1 }
      let(:last_page) { 4 }

      it { is_expected.to eq(['1', :gap, 4]) }
    end

    context 'when on second page' do
      let(:current_page) { 2 }
      let(:last_page) { 4 }

      it { is_expected.to eq([1, '2', :gap, 4]) }
    end

    context 'when on a middle page with gaps on both sides' do
      let(:current_page) { 3 }
      let(:last_page) { 7 }

      it { is_expected.to eq([1, :gap, '3', :gap, 7]) }
    end

    context 'when on second-to-last page' do
      let(:current_page) { 3 }
      let(:last_page) { 4 }

      it { is_expected.to eq([1, :gap, '3', 4]) }
    end

    context 'when on last page' do
      let(:current_page) { 4 }
      let(:last_page) { 4 }

      it { is_expected.to eq([1, :gap, '4']) }
    end

    context 'when there are only two pages' do
      context 'when on first page' do
        let(:current_page) { 1 }
        let(:last_page) { 2 }

        it { is_expected.to eq(['1', 2]) }
      end

      context 'when on last page' do
        let(:current_page) { 2 }
        let(:last_page) { 2 }

        it { is_expected.to eq([1, '2']) }
      end
    end
  end
end
