# frozen_string_literal: true

module Cda
  class LinkMigratedCasesService
    def self.call(status: nil, page: 1, per_page: 10, sort_by: :created_at, sort_direction: :asc)
      new(status:, page:, per_page:, sort_by:, sort_direction:).call
    end

    def initialize(status: nil, page: 1, per_page: 10, sort_by: :created_at, sort_direction: :asc)
      @status = status
      @page = page
      @per_page = per_page
      @sort_by = sort_by
      @sort_direction = sort_direction
    end

    def call
      Rails.logger.info 'FETCH_LINK_MIGRATED_CASES'
      Cda::LinkMigratedCasesCollection.fetch(
        status: @status, page: @page, per_page: @per_page,
        sort_by: @sort_by, sort_direction: @sort_direction
      )
    end
  end
end
