# frozen_string_literal: true

module PaginationHelper
  include Pagy::Frontend

  def pagination_info(pagy, item_name)
    # Pagy's output is not marked as html_safe even though it _is_ safe, so
    # we explicitly mark it as such here
    # rubocop:disable Rails/OutputSafety
    pagy_info(pagy, item_name: item_name.downcase.pluralize(pagy.count)).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  # Returns a condensed page series for mobile: first, current, and last pages
  # with :gap markers for omitted ranges. Mirrors the Gem Pagy's series format.
  #
  # Examples:
  #   page 1 of 4  => ["1", :gap, 4]
  #   page 3 of 7  => [1, :gap, "3", :gap, 7]
  def mobile_pagination_series(pagy)
    current_page = pagy.page

    prefix = case current_page
             when 1 then []
             when 2 then [1]
             else        [1, :gap]
             end

    suffix = case current_page
             when pagy.last     then []
             when pagy.last - 1 then [pagy.last]
             else                    [:gap, pagy.last]
             end

    prefix + [current_page.to_s] + suffix
  end

  def pagination_item_tag(item, pagy)
    case item
    when String  # Pagy encodes the active page as a String (e.g. "3") to distinguish it from neighbouring pages
      tag.li(class: "govuk-pagination__item govuk-pagination__item--current") do
        tag.a(item, href: pagy_url_for(pagy, item.to_i),
                    class: "govuk-link govuk-pagination__link",
                    aria: { label: "Page #{item}", current: "page" })
      end
    when Integer # neighbouring page numbers are Integers — rendered as clickable links
      tag.li(class: "govuk-pagination__item") do
        tag.a(item.to_s, href: pagy_url_for(pagy, item),
                         class: "govuk-link govuk-pagination__link",
                         aria: { label: "Page #{item}" })
      end
    when :gap then tag.li("⋯", class: "govuk-pagination__item govuk-pagination__item--ellipsis") # ellipsis placeholder for skipped page ranges
    end
  end
end
