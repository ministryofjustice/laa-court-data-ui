class StatsController < ApplicationController
  before_action :authorize_access

  def new
    @model = StatRange.new
  end

  def create
    from = DateFieldCollection.new(params.require(:stat_range), "from")
    to = DateFieldCollection.new(params.require(:stat_range), "to")
    @model = StatRange.new(from:, to:)

    return render :new unless @model.valid?

    @collection = Cda::LinkingStatCollection.find_from_range(@model.from.to_s, @model.to.to_s)

    render :show
  end

  private

  def authorize_access
    authorize!(:read, Cda::LinkingStatCollection)
  end
end
