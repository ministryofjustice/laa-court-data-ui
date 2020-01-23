# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  def show; end
end
