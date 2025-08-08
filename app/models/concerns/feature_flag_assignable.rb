module FeatureFlagAssignable
  extend ActiveSupport::Concern

  class_methods do
    def feature_flags
      ['view_appeals']
    end
  end

  included do |klass|
    klass.before_validation :reject_blank_flags!
    klass.validate :validate_flags
  end

  def feature_flag_enabled?(flag)
    feature_flags.include?(flag.to_s)
  end

  private

  def validate_flags
    feature_flags.all? do |flag|
      next if self.class.feature_flags.include?(flag)
      errors.add(:feature_flags, "#{flag} is not a valid feature flag")
    end
  end

  def reject_blank_flags!
    feature_flags&.reject!(&:blank?)
  end
end
