function Unlinking () {
  // rely on `name`` because id changes in error state
  //
  const unlinkReasonCode = document.getElementsByName('unlink_attempt[reason_code]')[0]
  const unlinkOtherReasonText = document.getElementsByName('unlink_attempt[other_reason_text]')[0]
  const otherReasonCode = '7'

  if (!unlinkReasonCode) { return false }
  if (!unlinkReasonCode.value) { hide() }
  if (unlinkReasonCode.value === otherReasonCode) { show() }

  unlinkReasonCode.onchange = function () {
    (this.value === otherReasonCode) ? show() : hide()
  }

  function show () {
    unlinkOtherReasonText.parentElement.classList.remove('govuk-select__conditional--hidden')
    unlinkOtherReasonText.parentElement.removeAttribute('aria-hidden')
  }

  function hide () {
    unlinkOtherReasonText.parentElement.classList.add('govuk-select__conditional--hidden')
    unlinkOtherReasonText.parentElement.setAttribute('aria-hidden', 'false')
  }
}
Unlinking()
