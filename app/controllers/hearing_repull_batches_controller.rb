# frozen_string_literal: true

class HearingRepullBatchesController < ApplicationController
  before_action :authorize_access

  def show
    @batch = Cda::HearingRepullBatch.find(params[:id])
  end

  def new
    @batch = Cda::HearingRepullBatch.new
  end

  def create
    @batch = Cda::HearingRepullBatch.new(params.require(:cda_hearing_repull_batch).permit(:maat_ids))
    if save_batch
      redirect_to(hearing_repull_batch_path(@batch), flash: { notice: t('.success') })
    else
      render :new
    end
  end

  private

  def authorize_access
    authorize!(:manage, Cda::HearingRepullBatch)
  end

  def save_batch
    @batch.save
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    Sentry.capture_exception(e)
    @batch.errors.add(:maat_id, cda_error_string(e) || t('hearing_repull_batches.create.failure'))
    false
  end
end
