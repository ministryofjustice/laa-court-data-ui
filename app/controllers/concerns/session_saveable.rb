module SessionSaveable
  extend ActiveSupport::Concern

  # We store session data directly in the session cookie. As such, we need to protect
  # against putting more in than the cookie can handle (4KB). This is the size
  # of the total cookie, not individual fields, so to make sure we stay inside this we
  # make sure that no individual field is above a sane limit. In general, 50 chars per
  # string keeps us comfortably safe for stashed search params. But for cookie return_to,
  # for example, this needs to be longer - which is fine, because it's a single string. So
  # we let the caller override max_string_length
  def session_safe(object, max_string_length: 50)
    session_representation = object.as_json
    case session_representation
    when Array
      session_representation.map { session_safe(it, max_string_length:) }
    when Hash
      session_representation.transform_values { session_safe(it, max_string_length:) }
    when String
      session_representation[...max_string_length]
    else
      session_representation
    end
  end
end
