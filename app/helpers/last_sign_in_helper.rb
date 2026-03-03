module LastSignInHelper
  def last_sign_in_status_class(last_sign_in_at)
    return 'lsi--grey' if last_sign_in_at.nil?
    last = last_sign_in_at.to_time
    return 'lsi--red' if last < 3.months.ago
    'lsi--green'
  end
end
