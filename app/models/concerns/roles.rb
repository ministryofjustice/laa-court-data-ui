# frozen_string_literal: true

module Roles
  extend ActiveSupport::Concern

  class_methods do
    def accepts_roles(*roles)
      cattr_accessor :valid_roles
      self.valid_roles = roles.map(&:to_s)
    end
  end

  included do |klass|
    klass.before_validation :reject_blank_role! if klass.respond_to?(:before_validation)
    klass.validate :validate_role_presence
    klass.validate :validate_role_inclusion
  end

  private

  def method_missing(method, *args)
    if role_booleans.include?(method.to_s)
      role?(method.to_s.delete('?'))
    else
      super
    end
  end

  def respond_to_missing?(method, *args)
    role_booleans.include?(method.to_s) || super
  end

  def role_booleans
    self.class.valid_roles.map { |role| "#{role}?" }
  end

  def role?(role)
    roles.include?(role.to_s)
  end

  def validate_role_presence
    errors.add(:roles, 'must have a role') if roles.blank? || roles.empty?
  end

  def validate_role_inclusion
    return if roles.blank? || roles.empty?
    roles.all? do |role|
      next if self.class.valid_roles.include?(role)
      errors.add(:roles, "#{role} is not a valid role")
    end
  end

  def reject_blank_role!
    roles&.reject!(&:blank?)
  end
end
