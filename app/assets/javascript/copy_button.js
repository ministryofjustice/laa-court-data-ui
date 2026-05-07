function copyText (textElementId, copyElementId, screenReaderAlertText, originalCopyText = 'Copy') {
  const textElement = document.querySelector(textElementId)
  const copyElement = document.querySelector(copyElementId)
  const screenReaderAlert = document.getElementById('copy-alert')

  if (textElement && copyElement) {
    copyElement.style.visibility = 'hidden'
    copyElement.textContent = 'Copied'
    copyElement.style.minWidth = copyElement.offsetWidth + 'px'
    copyElement.textContent = originalCopyText
    copyElement.style.visibility = ''

    copyElement.addEventListener('click', (e) => {
      e.preventDefault()
      const text = textElement.textContent.trim()
      window.navigator.clipboard.writeText(text)
      screenReaderAlert.textContent = screenReaderAlertText
      copyElement.classList.add('disable-click')
      copyElement.textContent = 'Copied'

      if (typeof window.gtag === 'function') {
        window.gtag('event', 'copy_button_click', {
          button_id: copyElementId.replace(/^#/, ''),
          page_path: window.location.pathname
        })
      }

      setTimeout(() => {
        screenReaderAlert.textContent = ''
        copyElement.classList.remove('disable-click')
        copyElement.textContent = originalCopyText
      }, 4000)

      copyElement.blur()
      return true
    })
  }
}

copyText('#defendant-name', '#copy-defendant-name', 'Defendant name copied')
copyText('#defendant-dob', '#copy-dob', 'Date of birth copied')
copyText('#defendant-case-urn', '#copy-case-urn', 'Case URN copied')
copyText('#defendant-ni-number', '#copy-ni-number', 'NI number copied')
copyText('#defendant-asn', '#copy-asn', 'ASN copied')
copyText('#defendant-maat-number', '#copy-maat-number', 'MAAT number copied')

copyText('#subject-name', '#copy-subject-name', 'Name copied')
copyText('#subject-dob', '#copy-subject-dob', 'Date of birth copied')
copyText('#subject-case-urn', '#copy-subject-case-urn', 'Case URN copied')
copyText('#subject-asn', '#copy-subject-asn', 'ASN copied')
copyText('#subject-maat-number', '#copy-subject-maat-number', 'MAAT number copied')
