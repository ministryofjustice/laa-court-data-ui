# frozen_string_literal: true

class DefendantsController < ApplicationController
  before_action :load_and_authorize_search

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.defendant.prosecution_case_reference) }),
                 (proc { |v| v.prosecution_case_path(v.controller.defendant.prosecution_case_reference) })

  def show
    add_breadcrumb defendant.name,
                   defendant_path(defendant.arrest_summons_number || defendant.national_insurance_number)
  end

  # TODO: this would be better as an update action IMO
  def remove_link
    if defendant.update(unlink_attributes)
      flash[:notice] = I18n.t('defendant.unlink.success')
    else
      flash[:alert] = I18n.t('defendant.unlink.failure')
    end

    redirect_to defendant_path(defendant.arrest_summons_number)
  end

  def unlink_attributes
    { user_name: current_user.username,
      unlink_reason_code: 1,
      unlink_reason_text: 'Wrong MAAT ID' }
  end

  def defendant
    @defendant ||= @search.execute.first
  end

  def load_and_authorize_search
    @search = Search.new(filter: 'defendant_reference', term: params[:id])
    authorize! :create, @search
  end
end
