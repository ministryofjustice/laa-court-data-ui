# frozen_string_literal: true

class HearingsController < ApplicationController
  skip_authorization_check

  def show
    authorize! :show, :hearings
  end
end
