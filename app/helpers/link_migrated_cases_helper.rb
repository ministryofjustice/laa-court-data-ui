# frozen_string_literal: true

module LinkMigratedCasesHelper
  COLUMN_CONFIG = {
    'case_urn' => { width: '150px', sortable: true, i18n_key: 'case_urn' },
    'defendant_name' => { width: '200px', sortable: true, i18n_key: 'defendant_name' },
    'xhibit_case_number' => { width: '130px', sortable: true, i18n_key: 'xhibit_ref' },
    'court_name' => { width: '100px', sortable: true, i18n_key: 'court' },
    'mode_of_trial' => { width: '140px', sortable: true, i18n_key: 'mode_of_trial' },
    'reason_for_man_linking' => { width: '130px', sortable: true, i18n_key: 'reason_for_man_linking_html' },
    'maat_id' => { width: '120px', sortable: true, i18n_key: 'maat_id' },
    'defendant_date_of_birth' => { width: '140px', sortable: true, i18n_key: 'defendant_date_of_birth' },
    'linked_at' => { width: '120px', sortable: true, i18n_key: 'linked_at' },
    'linked_by' => { width: '120px', sortable: true, i18n_key: 'linked_by' }
  }.freeze

  def column_config(col)
    COLUMN_CONFIG[col]
  end

  def column_value(column, m_case)
    case column
    when 'defendant_name' then [m_case['defendant_first_name'],
                                m_case['defendant_last_name']].compact.join(' ')
    when 'reason_for_man_linking' then m_case['process_errors']
    else m_case[column]
    end
  end

  def link_migrated_cases_sorter_link(column)
    direction = current_sort_column?(column) && params[:sort_direction] == 'asc' ? 'desc' : 'asc'
    link_migrated_cases_path(tab: params[:tab],
                             sort_column: column,
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
                             tab: params[:tab],
                             sort_column: params[:sort_column],
                             sort_direction: params[:sort_direction])
  end
end
