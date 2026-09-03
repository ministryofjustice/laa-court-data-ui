require "addressable"

module TableHelper
  def sorter_header(path:, direction_key:, column_key:, column:, label:, default_sort_column:)
    direction = render sorter_direction(direction_key) == "asc" ? "shared/up_icon" : "shared/down_icon"
    nondirection = render "shared/updown_icon"
    tag.th(class: "govuk-table__header", scope: "col") do
      sorter_link(path: path, direction_key: direction_key, column_key: column_key, column: column) do
        concat tag.span(label)
        concat tag.span(sorter_column?(column_key, column, default_sort_column) ? direction : nondirection)
      end
    end
  end

  def sorter_direction(key)
    params[key] == "desc" ? "desc" : "asc"
  end

  def target_direction(key)
    sorter_direction(key) == "asc" ? "desc" : "asc"
  end

  def sorter_column?(key, column, default_sort_column)
    if params[key].nil?
      column == default_sort_column
    else
      params[key] == column
    end
  end

  def sorter_link(path:, direction_key:, column_key:, column:, &block)
    link_to(sorter_path(path, direction_key, column_key, column),
            class: "app-no-wrap govuk-link--no-visited-state govuk-link--no-underline",
            id: column,
            "aria-label": t("tables.headings.sort.#{target_direction(direction_key)}", column:)) do
      block.call
    end
  end

  def sorter_path(path, direction_key, column_key, column)
    direction = target_direction(direction_key)
    path = Addressable::URI.parse(path)
    path.query_values = (path.query_values || {}).merge(column_key => column, direction_key => direction)
    path.to_s
  end
end
