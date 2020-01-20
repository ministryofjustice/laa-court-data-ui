# frozen_string_literal: true

class StatusController < ApplicationController
  skip_before_action :authenticate_user!

  def ping
    render json: {
      'app_branch' => ENV['APP_BRANCH'] || 'Not Available',
      'build_date' => ENV['BUILD_DATE'] || 'Not Available',
      'build_tag' => ENV['BUILD_TAG'] || 'Not Available',
      'commit_id' => ENV['COMMIT_ID'] || 'Not Available'
    }
  end
end
