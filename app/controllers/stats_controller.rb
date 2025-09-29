class StatsController < ApplicationController
  before_action :authorize_access

  def show
    @model = StatRange.new(stat_params)
    if @model.valid?
      @collection = Cda::LinkingStatCollection.find_from_range(@model.from.to_s, @model.to.to_s)
      render :show
    else
      render :new
    end
  end

  def new
    @model = StatRange.new
  end

  private

  def authorize_access
    authorize!(:read, Cda::LinkingStatCollection)
  end

  def stat_params
    if params[:stat_range]
      params.require(:stat_range).permit(:from, :to)
    else
      { from: 28.days.ago.to_date, to: 1.day.ago.to_date }
    end
  end
end
