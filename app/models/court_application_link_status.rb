class CourtApplicationLinkStatus
  def initialize(subject)
    @subject = subject
  end

  delegate :maat_reference, to: :@subject

  def maat_linked?
    maat_reference.present?
  end
end
