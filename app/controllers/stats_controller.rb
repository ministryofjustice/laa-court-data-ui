class StatsController < ApplicationController
  before_action :authorize_access

  def new
    @stat_range_dates = StatRange.new(stat_params)

    if @stat_range_dates.valid?

      @collection = Cda::LinkingStatCollection.find_from_range(
        Date.parse(@stat_range_dates.from).to_s,
        Date.parse(@stat_range_dates.to).to_s
      )
      @all_collection = Cda::LinkingStatCollection.find_from_range(
        100.years.ago.to_date.to_s,
        Date.today.to_s
      )
    end
    render :new
  end

  private

  def authorize_access
    authorize!(:read, Cda::LinkingStatCollection)
  end

  def stat_params
    if params[:stat_range]
      params.require(:stat_range).permit(:from, :to)
    else
      seven_days_ago = Time.zone.today - 7.days
      {
        from: seven_days_ago.beginning_of_week.strftime('%d/%m/%Y'),
        to: seven_days_ago.end_of_week.strftime('%d/%m/%Y')
      }
    end
  end
end
