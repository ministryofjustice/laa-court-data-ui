# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def accessibility_statement; end
end
