# frozen_string_literal: true

# Creates a chronologically sorted set of "items"
# with next and previous navigation helpers.
#
# Next and previous correlate to navigation over all
# a cases' hearing's hearing days.
#
class HearingPaginator
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  PageItem = Struct.new(:id, :hearing_date)

  def initialize(prosecution_case, column: 'date', direction: 'asc', page: 0)
    @prosecution_case = prosecution_case
    @current_page = page.to_i
    @column = column
    @direction = direction
  end

  def current_page
    @current_page ||= 0
  end

  def current_item
    items[current_page || first_page]
  end

  def items
    @items ||= sorted_hearing_items
  end

  def first_page?
    current_page == first_page
  end

  def first_page
    0
  end

  def last_page?
    current_page == last_page
  end

  def last_page
    [items.size - 1, 0].max
  end

  def next_page_link
    # TODO: add <span class="govuk-visually-hidden"> set of pages</span> within hyperlink ?!
    link_to(t('hearings.show.pagination.next_page'),
            hearing_path(id: next_item.id,
                         urn: @prosecution_case.prosecution_case_reference,
                         page: next_page,
                         column: @column,
                         direction: @direction),
            class: 'moj-pagination__link')
  end

  def previous_page_link
    # TODO: add <span class="govuk-visually-hidden"> set of pages</span> within hyperlink ?!
    link_to(t('hearings.show.pagination.previous_page'),
            hearing_path(id: previous_item.id,
                         urn: @prosecution_case.prosecution_case_reference,
                         page: previous_page,
                         column: @column,
                         direction: @direction),
            class: 'moj-pagination__link')
  end

  private

  def next_item
    items[next_page]
  end

  def next_page
    [current_page + 1, last_page].min
  end

  def previous_item
    items[previous_page]
  end

  def previous_page
    [current_page - 1, first_page].max
  end

  def sorted_hearing_items
    @prosecution_case.hearings_sort_column = @column
    @prosecution_case.hearings_sort_direction = @direction
    @prosecution_case.sorted_hearing_summaries_with_day.map do |hearing|
      PageItem.new(hearing.id, hearing.day)
    end
  end
end
