# frozen_string_literal: true

class RepullBatchesController < ApplicationController
  before_action :authorize_access

  def show
    @batch = Cda::HearingRepullBatch.find(params[:id])
  end

  def new; end

  def create
    @batch = Cda::HearingRepullBatch.create(params.permit(:maat_ids))
    redirect_to repull_batch_path(@batch), flash: { notice: t('.success') }
  end

  private

  def authorize_access
    authorize!(:manage, Cda::HearingRepullBatch)
  end
end
