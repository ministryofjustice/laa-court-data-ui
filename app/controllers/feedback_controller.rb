# frozen_string_literal: true

class FeedbackController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new feedback_params
    if @feedback.valid?
      submit_feedback
      redirect_to authenticated_root_path, notice: I18n.t('feedback.submitted.success')
    else
      render new_feedback_path
    end
  end

  private

  def submit_feedback
    FeedbackMailer.notify(
      email: feedback_params[:email],
      rating: feedback_params[:rating],
      comment: feedback_params[:comment],
      environment: environment
    ).deliver_later!
  end

  def feedback_params
    params.require(:feedback).permit(:comment, :email, :rating, :subject)
  end

  def environment
    ENV['ENV'] || ''
  end
end
