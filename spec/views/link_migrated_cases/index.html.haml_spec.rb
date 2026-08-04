# frozen_string_literal: true

RSpec.describe 'link_migrated_cases/index.html.haml', type: :view do
  def expect_table_headers(*headers)
    expect(rendered).to have_css('thead.govuk-table__head tr th', count: headers.length)

    headers.each_with_index do |header, index|
      expect(rendered).to have_css("thead.govuk-table__head tr th:nth-child(#{index + 1})", text: header)
    end
  end

  def expect_first_row_cells(*cells)
    expect(rendered).to have_css('tbody.govuk-table__body tr:nth-child(1) td', count: cells.length)

    cells.each_with_index do |cell, index|
      expect(rendered).to have_css("tbody.govuk-table__body tr:nth-child(1) td:nth-child(#{index + 1})",
                                   text: cell)
    end
  end

  shared_examples 'renders empty state' do
    let(:cases) { [] }

    before { allow(pagy).to receive(:pages).and_return(1) }

    it 'renders the no results message' do
      render
      expect(rendered).to include('No link migrated cases found')
    end

    it 'does not render pagination' do
      render
      expect(rendered).to have_no_css('.moj-pagination')
    end
  end

  let(:cases_count) do
    { 'action_required' => 3, 'manually_linked' => 5, 'auto_linked' => 2, 'pending' => 7 }
  end

  let(:cases) do
    [
      { 'case_urn' => 'TEST12345', 'defendant_first_name' => 'John', 'defendant_last_name' => 'Smith',
        'xhibit_case_number' => 'X123', 'court_name' => 'Southwark', 'mode_of_trial' => 'Summary',
        'maat_id' => '1234567', 'defendant_date_of_birth' => '01/01/1990', 'linked_at' => '2024-03-01',
        'linked_by' => 'Jane Doe', 'process_errors' => 'Missing case details' }
    ]
  end

  let(:pagy) { instance_double(Pagy, pages: 1, prev: nil, next: nil) }

  before do
    assign(:tab, 'pending')
    assign(:cases, cases)
    assign(:cases_count, cases_count)
    assign(:columns, %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial])
    assign(:pagy, pagy)
    allow(view).to receive_messages(govuk_page_heading: '<h1>Link migrated cases</h1>',
                                    link_migrated_cases_sorter_direction: 'asc',
                                    link_migrated_cases_sorter_link: '/link_migrated_cases',
                                    current_sort_column?: false)
    allow(view).to receive(:render).and_call_original
  end

  it 'renders the page heading' do
    render
    expect(rendered).to include('Link migrated cases')
  end

  it 'renders the sub-navigation tabs' do
    render
    expect(rendered)
      .to have_css('ul.moj-sub-navigation__list li:nth-child(1)', text: 'Need linking (3)')
      .and have_css('ul.moj-sub-navigation__list li:nth-child(2)', text: 'Manually linked cases (5)')
      .and have_css('ul.moj-sub-navigation__list li:nth-child(3)', text: 'Auto linked cases (2)')
      .and have_css('ul.moj-sub-navigation__list li:nth-child(4)', text: 'Pending (7)')
  end

  it 'marks `pending` tab as active' do
    render
    expect(rendered).to have_css('[aria-current="page"]', text: /Pending/)
  end

  it 'renders the table with column headers' do
    render
    expect_table_headers('Case URN', 'Defendant name', 'Xhibit ref.', 'Court', 'Mode of trial')
  end

  it 'renders case data rows' do
    render
    expect_first_row_cells('TEST12345', 'John Smith', 'X123', 'Southwark', 'Summary')
  end

  context 'when there are no cases' do
    it_behaves_like 'renders empty state'
  end

  context 'when on the `action_required` tab' do
    before do
      assign(:tab, 'action_required')
      assign(:columns, %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial
                          reason_for_man_linking maat_id])
    end

    it 'marks `action_required` tab as active' do
      render
      expect(rendered).to have_css('[aria-current="page"]', text: /Need linking/)
    end

    it 'renders the table with column headers' do
      render
      expect_table_headers('Case URN', 'Defendant name', 'Xhibit ref.', 'Court', 'Mode of trial',
                           /Reason for/, 'MAAT ID')
    end

    it 'renders case data rows' do
      render
      expect_first_row_cells('TEST12345', 'John Smith', 'X123', 'Southwark', 'Summary',
                             'Missing case details', '1234567')
    end

    context 'when there are no cases' do
      it_behaves_like 'renders empty state'
    end
  end

  context 'when on the `manually_linked` tab' do
    before do
      assign(:tab, 'manually_linked')
      assign(:columns,
             %w[case_urn_new_tab maat_id defendant_name defendant_date_of_birth linked_at linked_by])
    end

    it 'marks `manually_linked` tab as active' do
      render
      expect(rendered).to have_css('[aria-current="page"]', text: /Manually linked cases/)
    end

    it 'renders the table with column headers' do
      render
      expect_table_headers(/Case URN/, 'MAAT ID', 'Defendant name', 'Date of birth', 'Linked date',
                           'Linked by')
    end

    it 'renders case data rows' do
      render
      expect_first_row_cells('TEST12345', '1234567', 'John Smith', '01/01/1990', '2024-03-01', 'Jane Doe')
    end

    context 'when there are no cases' do
      it_behaves_like 'renders empty state'
    end
  end

  context 'when on the `auto_linked` tab' do
    before do
      assign(:tab, 'auto_linked')
      assign(:columns, %w[case_urn_new_tab maat_id defendant_name defendant_date_of_birth auto_linked_at])
    end

    it 'marks `auto_linked` tab as active' do
      render
      expect(rendered).to have_css('[aria-current="page"]', text: /Auto linked cases/)
    end

    it 'renders the table with column headers' do
      render
      expect_table_headers(/Case URN/, 'MAAT ID', 'Defendant name', 'Date of birth', 'Auto linked date')
    end

    it 'renders case data rows' do
      render
      expect_first_row_cells('TEST12345', '1234567', 'John Smith', '01/01/1990', '2024-03-01')
    end

    context 'when there are no cases' do
      it_behaves_like 'renders empty state'
    end
  end
end
