# frozen_string_literal: true

RSpec.describe LinkMigratedCasesHelper, type: :helper do
  describe '#column_config' do
    it 'returns configuration for a known column' do
      expect(helper.column_config('case_urn')).to include(:width, :sortable, :i18n_key)
    end

    it 'returns nil for unknown column' do
      expect(helper.column_config('non_existent')).to be_nil
    end
  end

  describe '#formatted_process_errors' do
    it 'returns the original value when not a hash' do
      expect(helper.formatted_process_errors('some error')).to eq('some error')
    end

    it 'formats error and message when present' do
      err = { error: 'ERR', message: 'Something went wrong' }
      expect(helper.formatted_process_errors(err)).to eq('ERR - Something went wrong')
    end

    it 'returns only error when message absent' do
      err = { error: 'ONLY_ERR' }
      expect(helper.formatted_process_errors(err)).to eq('ONLY_ERR')
    end

    it 'returns only message when error absent' do
      err = { 'message' => 'ONLY_MESSAGE' }
      expect(helper.formatted_process_errors(err)).to eq('ONLY_MESSAGE')
    end

    it 'falls back to stringified hash when both blank' do
      err = { error: nil, message: nil }
      expect(helper.formatted_process_errors(err)).to eq(err.to_s)
    end
  end

  describe '#link_maat_id_url' do
    it 'returns a link to the defendant linking page with the urn param' do
      allow(helper).to receive(:link_defendant_path).with(123,
                                                          urn: 'URN123').and_return('/link/123?urn=URN123')

      result = helper.link_maat_id_url(123, 'URN123')
      expect(result).to include('Link MAAT ID')
      expect(result).to include('href="/link/123?urn=URN123"')
      expect(result).to include('govuk-link')
    end
  end

  describe '#column_value' do
    let(:base_case) do
      {
        'defendant_first_name' => 'John',
        'defendant_last_name' => 'Doe',
        'linked_at' => '2024-01-01',
        'case_urn' => 'URN-1',
        'process_errors' => { error: 'E', message: 'M' },
        'defendant_id' => 555,
        'x' => 'y'
      }
    end

    before do
      allow(helper).to receive(:link_defendant_path).and_return('/link/555?urn=URN-1')
    end

    it 'joins defendant first and last name' do
      expect(helper.column_value('defendant_name', base_case)).to eq('John Doe')
    end

    it 'returns linked_at for auto_linked_at column' do
      expect(helper.column_value('auto_linked_at', base_case)).to eq('2024-01-01')
    end

    it 'returns case_urn for case_urn_new_tab column' do
      expect(helper.column_value('case_urn_new_tab', base_case)).to eq('URN-1')
    end

    it 'uses formatted_process_errors for reason_for_man_linking column' do
      allow(helper).to receive(:formatted_process_errors).and_call_original

      expect(helper.column_value('reason_for_man_linking', base_case)).to eq('E - M')
      expect(helper).to have_received(:formatted_process_errors).with(base_case['process_errors'])
    end

    it 'returns a link for link_maat_id column' do
      result = helper.column_value('link_maat_id', base_case)
      expect(result).to include('href="/link/555?urn=URN-1"')
      expect(result).to include('Link MAAT ID')
    end

    it 'falls back to raw value for other columns' do
      expect(helper.column_value('x', base_case)).to eq('y')
    end
  end

  describe '#link_migrated_cases_sorter_link' do
    it 'asks for link_migrated_cases_path with toggled direction when currently asc' do
      allow(helper).to receive_messages(params: ActionController::Parameters.new(tab: 'all',
                                                                                 sort_direction: 'asc',
                                                                                 sort_column: 'col'),
                                        link_migrated_cases_path: '/dummy')

      helper.link_migrated_cases_sorter_link('col')
      expect(helper).to have_received(:link_migrated_cases_path).with(tab: 'all', sort_column: 'col',
                                                                      sort_direction: 'desc')
    end

    it 'sets direction to asc when not currently sorted by the column' do
      allow(helper).to receive_messages(params: ActionController::Parameters.new(tab: 't',
                                                                                 sort_direction: 'asc',
                                                                                 sort_column: 'other'),
                                        link_migrated_cases_path: '/dummy')

      helper.link_migrated_cases_sorter_link('col2')
      expect(helper).to have_received(:link_migrated_cases_path).with(tab: 't', sort_column: 'col2',
                                                                      sort_direction: 'asc')
    end
  end

  describe '#link_migrated_cases_sorter_direction' do
    it 'returns desc only when param is desc' do
      allow(helper).to receive(:params).and_return({ sort_direction: 'desc' })
      expect(helper.link_migrated_cases_sorter_direction).to eq('desc')

      allow(helper).to receive(:params).and_return({ sort_direction: 'asc' })
      expect(helper.link_migrated_cases_sorter_direction).to eq('asc')

      allow(helper).to receive(:params).and_return({})
      expect(helper.link_migrated_cases_sorter_direction).to eq('asc')
    end
  end

  describe '#current_sort_column?' do
    it 'returns true for default columns when sort_column param is nil' do
      allow(helper).to receive(:params).and_return({})
      expect(helper.current_sort_column?('case_urn')).to be true
      expect(helper.current_sort_column?('case_urn_new_tab')).to be true
      expect(helper.current_sort_column?('defendant_name')).to be false
    end

    it 'returns true only when params sort_column matches' do
      allow(helper).to receive(:params).and_return({ sort_column: 'abc' })
      expect(helper.current_sort_column?('abc')).to be true
      expect(helper.current_sort_column?('other')).to be false
    end
  end

  describe '#page_url' do
    it 'calls link_migrated_cases_path with page and current params' do
      allow(helper).to receive_messages(params: ActionController::Parameters.new(tab: 'xx',
                                                                                 sort_column: 'sc',
                                                                                 sort_direction: 'desc'),
                                        link_migrated_cases_path: '/dummy')

      helper.page_url(3)
      expect(helper).to have_received(:link_migrated_cases_path).with(page: 3, tab: 'xx', sort_column: 'sc',
                                                                      sort_direction: 'desc')
    end
  end
end
