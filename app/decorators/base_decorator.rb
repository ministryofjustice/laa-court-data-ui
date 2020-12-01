# frozen_string_literal: true

class BaseDecorator < SimpleDelegator
  def initialize(object, context = nil)
    @object = object
    @context = context
    super(@object)
  end

  attr_reader :object, :context

  alias view context
  alias h context

  delegate :translate, :t, :tag, :safe_join, to: :context
end
