# frozen_string_literal: true

class CasesController < ApplicationController
  skip_authorization_check

  def show
    authorize! :show, :cases
  end
end
