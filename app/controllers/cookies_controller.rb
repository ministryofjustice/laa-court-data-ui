# frozen_string_literal: true

class CookiesController < ApplicationController
    skip_before_action :authenticate_user!
    skip_authorization_check

    def new
        @cookie = Cookie.new
    end

    def cookie_details
    end
end
  