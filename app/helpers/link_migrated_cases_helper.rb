# frozen_string_literal: true

module LinkMigratedCasesHelper
  COLUMN_CONFIG = {
    "auto_linked_at" => { width: "120px", sortable: true, i18n_key: "auto_linked_at" },
    "case_urn" => { width: "150px", sortable: true, i18n_key: "case_urn" },
    "case_urn_new_tab" => { width: "160px", sortable: true, i18n_key: "case_urn_new_tab_html" },
    "defendant_name" => { width: "180px", sortable: true, i18n_key: "defendant_name" },
    "xhibit_case_number" => { width: "130px", sortable: true, i18n_key: "xhibit_ref" },
    "court_name" => { width: "100px", sortable: true, i18n_key: "court" },
    "mode_of_trial" => { width: "140px", sortable: true, i18n_key: "mode_of_trial" },
    "reason_for_man_linking" => { width: "130px", sortable: true, i18n_key: "reason_for_man_linking_html" },
    "maat_id" => { width: "100px", sortable: true, i18n_key: "maat_id" },
    "defendant_date_of_birth" => { width: "120px", sortable: true, i18n_key: "defendant_date_of_birth" },
    "linked_at" => { width: "120px", sortable: true, i18n_key: "linked_at" },
    "linked_by" => { width: "120px", sortable: true, i18n_key: "linked_by" },
    "action" => { width: "120px", sortable: false, i18n_key: "action" },
  }.freeze

  HANDLERS = {
    "defendant_name" => :handle_defendant_name,
    "auto_linked_at" => :handle_auto_linked_at,
    "case_urn_new_tab" => :handle_case_urn_new_tab,
    "reason_for_man_linking" => :handle_reason_for_man_linking,
    "link_maat_id" => :handle_link_maat_id,
    "linked_at" => :handle_linked_at,
    "defendant_date_of_birth" => :handle_defendant_date_of_birth,
  }.freeze

  def column_config(col)
    COLUMN_CONFIG[col]
  end

  def formatted_process_errors(process_errors)
    return process_errors unless process_errors.as_json.is_a?(Hash)

    formatted_values = process_errors.with_indifferent_access.slice(:error, :message).values.compact_blank
    formatted_values.join(" - ").presence || process_errors.to_s
  end

  def link_maat_id_url(id)
    link_to("Link MAAT ID",
            link_defendant_path(defendant_id, urn: case_urn),
            class: "govuk-link govuk-link--no-visited-state")
  end

  def case_urn_new_tab_url(case_urn)
    link_to(case_urn,
            prosecution_case_path(case_urn),
            class: "govuk-link govuk-link--no-visited-state",
            target: "_blank", rel: "noopener")
  end

  def case_urn_new_tab_url(case_urn)
    link_to(case_urn,
            prosecution_case_path(case_urn),
            class: "govuk-link govuk-link--no-visited-state",
            target: "_blank", rel: "noopener")
  end

  def column_value(column, m_case)
    case column
    when "auto_linked_at" then handle_auto_linked_at(m_case)
    when "case_urn" then handle_case_urn(m_case)
    when "case_urn_new_tab" then handle_case_urn_new_tab(m_case)
    when "defendant_date_of_birth" then handle_defendant_date_of_birth(m_case)
    when "defendant_name" then handle_defendant_name(m_case)
    when "action" then handle_action(m_case)
    when "linked_at" then handle_linked_at(m_case)
    when "reason_for_man_linking" then handle_reason_for_man_linking(m_case)
    else m_case[column]
    end
  end

  def link_migrated_cases_sorter_link(column)
    direction = current_sort_column?(column) && params[:sort_direction] == "asc" ? "desc" : "asc"
    link_migrated_cases_path(tab: params[:tab],
                             sort_column: column,
                             sort_direction: direction)
  end

  def link_migrated_cases_sorter_direction
    params[:sort_direction] == "desc" ? "desc" : "asc"
  end

  def current_sort_column?(column)
    if params[:sort_column].nil?
      %w[case_urn case_urn_new_tab].include?(column)
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

private

  def handle_defendant_name(m_case)
    [m_case["defendant_first_name"], m_case["defendant_last_name"]].compact.join(" ")
  end

  def handle_auto_linked_at(m_case)
    format_date(m_case["linked_at"], "%d/%m/%Y")
  end

  def handle_case_urn(m_case)
    tag.div(class: "tags") do
      safe_join([m_case["case_urn"], case_type_tag(m_case["case_type"])].compact, "<br>".html_safe)
    end
  end

  def handle_case_urn_new_tab(m_case)
    tag.div(class: "tags") do
      safe_join([case_urn_new_tab_url(m_case["case_urn"]), case_type_tag(m_case["case_type"])].compact, "<br>".html_safe)
    end
  end

  def handle_reason_for_man_linking(m_case)
    formatted_process_errors(m_case["process_errors"])
  end

  def handle_action(m_case)
    link_maat_id_url(m_case["defendant_id"], m_case["case_urn"])
  end

  def handle_linked_at(m_case)
    format_date(m_case["linked_at"], "%d/%m/%Y")
  end

  def handle_defendant_date_of_birth(m_case)
    format_date(m_case["defendant_date_of_birth"], "%-d %b %Y")
  end

  def format_date(value, format)
    return if value.blank?

    Time.zone.parse(value).strftime(format)
  rescue ArgumentError
    value
  end
end
