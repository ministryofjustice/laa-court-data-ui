# frozen_string_literal: true

class HelpController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def cookies; end
end
