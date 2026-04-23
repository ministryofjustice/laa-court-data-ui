# frozen_string_literal: true

module LinkMigratedCasesHelper
  def link_migrated_cases_sorter_link(column)
    direction = current_sort_column?(column) && params[:sort_direction] == 'asc' ? 'desc' : 'asc'
    link_migrated_cases_path(sort_column: column,
                             sort_direction: direction)
  end

  def link_migrated_cases_sorter_direction
    params[:sort_direction] == 'desc' ? 'desc' : 'asc'
  end

  def current_sort_column?(column)
    if params[:sort_column].nil?
      column == 'case_urn'
    else
      params[:sort_column] == column
    end
  end

  def page_url(page_num)
    link_migrated_cases_path(page: page_num,
                             sort_column: params[:sort_column],
                             sort_direction: params[:sort_direction])
  end
end
