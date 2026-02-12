class SubjectsController < ApplicationController
  before_action :load_and_authorize_application
  before_action :set_breadcrumbs

  # GET /court_applications/:court_application_id/subject
  def show
    @form_model = @application.maat_linked? ? load_unlink_attempt : load_link_attempt

    return unless params.fetch(:include_offence_history, 'false') == 'true'

    @offence_history_collection = Cda::OffenceHistoryCollection.find_from_id_and_urn(
      @application.defendant.id,
      @application.prosecution_case_reference
    )
  end

  # POST /court_applications/:court_application_id/subject/link
  def link
    @form_model = LinkAttempt.new(defendant_id: @subject.subject_id, username: current_user.username,
                                  maat_reference: params.dig(:link_attempt, :maat_reference))

    if params[:maat_ref_required] == 'true'
      @form_model.validate!(:maat_ref_required)
    else
      @form_model.maat_reference = nil
      @form_model.validate!
    end

    Cda::CourtApplicationLaaReference.create!(@form_model)

    redirect_to court_application_subject_path(@application.application_id), flash: { notice: t('.success') }
  rescue ActiveResource::ConnectionError => e
    handle_link_failure(e.message, e)
    render :show
  rescue ActiveModel::ValidationError
    render :show
  end

  # POST /court_applications/:court_application_id/subject/unlink
  def unlink
    @form_model = load_unlink_attempt
    @form_model.validate!
    Cda::CourtApplicationLaaReference.update!(@form_model)
    redirect_to court_application_subject_path(@application.application_id),
                flash: { notice: t('.success') }
  rescue ActiveResource::ConnectionError => e
    handle_unlink_failure(e.message, e)
    render :show
  rescue ActiveModel::ValidationError # No action needed: the form already contains the validation errors
    render :show
  end

  private

  def load_and_authorize_application
    @application = Cda::CourtApplication.find(params[:court_application_id])
    @subject = @application.subject_summary
    authorize! :show, @application
  end

  def set_breadcrumbs
    # Example:
    # Home > Search > Case XXXXXXXXXX > Appeal/Breach/Poca > John Doe

    add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
    add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

    reference = @application.application_reference
    add_breadcrumb prosecution_case_name(reference), prosecution_case_path(reference)
    add_breadcrumb t("subjects.#{@application.application_category}"),
                   court_application_path(@application.application_id)
    add_breadcrumb @subject.name
  end

  def load_unlink_attempt
    UnlinkAttempt.new(
      defendant_id: @subject.subject_id,
      username: current_user.username,
      reason_code: params.dig(:unlink_attempt, :reason_code).to_i,
      other_reason_text: params.dig(:unlink_attempt, :other_reason_text),
      maat_reference: @application.maat_reference
    )
  end

  def load_link_attempt
    LinkAttempt.new(
      defendant_id: @subject.subject_id,
      username: current_user.username,
      maat_reference: params.dig(:link_attempt, :maat_reference)
    )
  end

  def handle_link_failure(message, exception = nil)
    logger.warn "LINK FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:maat_reference, cda_error_string(exception) || t('subjects.link.failure'))
  end

  def handle_unlink_failure(message, exception = nil)
    logger.warn "UNLINK FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:reason_code, cda_error_string(exception) || t('subjects.unlink.failure'))
  end

  def cda_error_string_context
    @application&.application_category
  end
end
