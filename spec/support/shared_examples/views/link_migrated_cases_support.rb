# frozen_string_literal: true

shared_examples 'renders empty state' do
  let(:cases) { [] }

  before { allow(pagy).to receive(:pages).and_return(1) }

  it 'renders the no results message' do
    render
    expect(rendered).to include('No migrated cases found')
  end

  it 'does not render pagination' do
    render
    expect(rendered).to have_no_css('.moj-pagination')
  end
end

def expect_table_headers(*headers)
  expect(rendered).to have_css('thead.govuk-table__head tr th', count: headers.length)

  headers.each_with_index do |header, index|
    expect(rendered).to have_css("thead.govuk-table__head tr th:nth-child(#{index + 1})", text: header)
  end
end

def expect_first_row_cells(*cells)
  expect(rendered).to have_css('tbody.govuk-table__body tr:nth-child(1) td', count: cells.length)

  cells.each_with_index do |cell, index|
    selector = "tbody.govuk-table__body tr:nth-child(1) td:nth-child(#{index + 1})"

    if cell.is_a?(Hash)
      # Allow expectations like { text: 'Link MAAT ID', href: '/path' }
      text = cell[:text] || cell['text']
      href = cell[:href] || cell['href']

      expect(rendered).to have_css(selector)
      expect(rendered).to have_css("#{selector} a", text: text) if text
      expect(rendered).to have_css("#{selector} a[href='#{href}']") if href
    else
      expect(rendered).to have_css(selector, text: cell)
    end
  end
end
