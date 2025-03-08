# frozen_string_literal: true

class FeatureFlag
  def self.enabled?(feature_name)
    flag = ENV.fetch(feature_name.upcase.to_s, false)
    ActiveModel::Type::Boolean.new.cast(flag)
  end
end
