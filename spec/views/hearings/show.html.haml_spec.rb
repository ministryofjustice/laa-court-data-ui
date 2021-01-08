# frozen_string_literal: true

RSpec.describe 'hearings/show.html.haml', type: :view do
  include RSpecHtmlMatchers

  let(:hearing) { CourtDataAdaptor::Resource::Hearing.new }

  before do
    allow(view).to receive(:govuk_page_title).and_return 'A heading'
    assign(:hearing, hearing)
  end

  context 'with defendant_names' do
    before { allow(hearing).to receive(:defendant_names).and_return(['Joe Bloggs', 'Fred Dibnah']) }

    it 'displays defendant names with line breaks' do
      render
      expect(rendered).to have_tag('td.govuk-table__cell', text: /Joe Bloggs.*Fred Dibnah/) do
        with_tag(:br)
      end
    end
  end

  context 'with prosecution_advocate_names' do
    before do
      allow(hearing)
        .to receive(:prosecution_advocate_names)
        .and_return(['Percy Prosecutor', 'Linda Lawless'])
    end

    it 'displays prosecution advocate names with line breaks' do
      render
      expect(rendered).to have_tag('td.govuk-table__cell', text: /Percy Prosecutor.*Linda Lawless/) do
        with_tag(:br)
      end
    end
  end

  context 'with judge_names' do
    before do
      allow(hearing)
        .to receive(:judge_names)
        .and_return(['Mr Justice Pomfrey', 'Ms Justice Arden'])
    end

    it 'displays judge names with line breaks' do
      render
      expect(rendered).to have_tag('td.govuk-table__cell', text: /Mr Justice Pomfrey.*Ms Justice Arden/) do
        with_tag(:br)
      end
    end
  end
end
