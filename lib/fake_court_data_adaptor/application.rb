# frozen_string_literal: true

require 'sinatra'
require 'pry'
require 'pry-byebug'
require 'awesome_print'
require_relative 'data/prosecution_case'
require_relative 'search/prosecution_case'

module FakeCourtDataAdaptor
  class Application < Sinatra::Base
    get '/' do
      'fake court data adaptor'
    end

    get '/prosecution_cases' do
      content_type('application/vnd.api+json')
      search = Search::ProsecutionCase.new
      filter = params[:filter]
      search.where(filter) if params
    end
  end
end
