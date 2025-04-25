class CourtApplicationLinkStatus
  # When a MAAT reference is linked or unlinked in the UI, the process isn't changed by CDA immediately.
  # Instead it's pushed onto a queue. However this can create a confusing UI, where a user sees a
  # confirmation message of a change having been made, but also sees UI details as though the change
  # has not been made. So to work around this we temporarily force the UI to display the state
  # resulting from the change even if that change has not yet been applied, by using `linked=1234567`
  # or `unlinked=true` in the query string.
  def initialize(subject, params)
    @subject = subject
    @params = params
  end

  def maat_reference
    return unless maat_linked?

    @params[:linked].presence || @subject.maat_reference
  end

  def maat_linked?
    return false if @params[:unlinked]
    return true if @params[:linked]

    @subject.maat_reference.present?
  end
end
