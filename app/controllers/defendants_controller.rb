# frozen_string_literal: true

class DefendantsController < ApplicationController
  skip_authorization_check

  def show
    authorize! :show, :defendants
  end
end
