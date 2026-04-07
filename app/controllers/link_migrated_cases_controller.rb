# frozen_string_literal: true

class LinkMigratedCasesController < ApplicationController
  authorize_resource class: false

  def show; end
end
