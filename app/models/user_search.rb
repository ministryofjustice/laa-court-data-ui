class UserSearch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_string, :string
  attribute :recent_sign_ins, :boolean
  attribute :old_sign_ins, :boolean

  def filters_applied?
    search_string.present? || recent_sign_ins || old_sign_ins
  end

  def toggle_class
    filters_applied? ? 'moj-js-hidden' : ''
  end

  def form_class
    filters_applied? ? '' : 'moj-js-hidden'
  end

  def recent_count
    User.where('last_sign_in_at >= ?', 3.months.ago).count
  end

  def old_count
    User.where('last_sign_in_at IS NULL OR last_sign_in_at < ?', 3.months.ago).count
  end
end
