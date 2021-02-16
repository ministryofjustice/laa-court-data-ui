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

  PageItem = Struct.new(:id, :hearing_date, :hearing_type, :providers)

  # rubocop:disable Rails/HelperInstanceVariable
  def initialize(prosecution_case, options = {})
    @prosecution_case = prosecution_case
    @current_page = options.fetch(:page, nil).to_i
    @sort_order = options.fetch(:sort_order, nil)
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def items
    sorted_hearing_page_items
  end

  def current_item
    items[current_page || first_page]
  end

  attr_writer :current_page

  def current_page
    @current_page ||= 0
  end

  def first_page
    0
  end

  def last_page
    [items.size - 1, 0].max
  end

  def first_page?
    current_page == first_page
  end

  def last_page?
    current_page == last_page
  end

  def next_page_link
    link_to(t('hearings.show.pagination.next_page'),
            hearing_path(id: next_item.id,
                         urn: prosecution_case.prosecution_case_reference,
                         page: next_page,
                         sort_order: sort_order),
            class: 'govuk-link app-pagination-next')
  end

  def previous_page_link
    link_to(t('hearings.show.pagination.previous_page'),
            hearing_path(id: previous_item.id,
                         urn: prosecution_case.prosecution_case_reference,
                         page: previous_page,
                         sort_order: sort_order),
            class: 'govuk-link app-pagination-previous')
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

  def sorted_hearing_page_items
    case sort_order
    when 'date_desc'
      hearing_page_items.sort_by(&:hearing_date).reverse
    when 'type_asc'
      hearing_page_items.sort_by(&:hearing_type)
    when 'type_desc'
      hearing_page_items.sort_by(&:hearing_type).reverse
    when 'provider_asc'
      hearing_page_items.sort_by(&:providers)
    when 'provider_desc'
      hearing_page_items.sort_by(&:providers).reverse
    else
      hearing_page_items.sort_by(&:hearing_date)
    end
  end

  attr_reader :prosecution_case, :sort_order

  def hearing_page_items
    prosecution_case.hearings.each_with_object([]) do |hearing, result|
      hearing.hearing_days.map do |day|
        result << PageItem.new(hearing.id, day.to_datetime, hearing.hearing_type, hearing.providers)
      end
    end
  end
end
