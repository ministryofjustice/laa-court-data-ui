function Unlinking () {
  const unlinkReasonCode = document.getElementById('unlink-attempt-reason-code-field')
  const unlinkOtherReasonText = document.getElementById('unlink-attempt-other-reason-text-field')

  if (!unlinkReasonCode) { return }

  if (unlinkOtherReasonText) { setAttr() }

  // TODO: should really rely on a data-text-required flag set by backend
  //
  unlinkReasonCode.onchange = function () {
    (this.value === '7') ? removeAttr() : setAttr()
  }

  function removeAttr () {
    unlinkOtherReasonText.parentElement.classList.remove('govuk-select__conditional--hidden')
    unlinkOtherReasonText.parentElement.removeAttribute('aria-hidden')
  }

  function setAttr () {
    unlinkOtherReasonText.parentElement.classList.add('govuk-select__conditional--hidden')
    unlinkOtherReasonText.parentElement.setAttribute('aria-hidden', 'false')
  }
}
Unlinking()
