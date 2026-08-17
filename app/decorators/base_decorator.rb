# frozen_string_literal: true

class BaseDecorator < SimpleDelegator
  def initialize(object, context = nil)
    @object = object
    @context = context
    super(@object)
  end

  attr_reader :object, :context

  alias_method :view, :context
  alias_method :h, :context

  delegate :translate, :t, :tag, :safe_join, :decorate, :decorate_all, to: :context
end
