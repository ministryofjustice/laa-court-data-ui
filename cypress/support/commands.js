// attempts to login to vcd with given username (string) and password (strings)
Cypress.Commands.add('login', (username, password) => {
  cy.get('input#user-login-field').clear().type(username)
  cy.get('input#user-password-field').clear().type(password)
  cy.get('*[data-cy="login-submit"]').click()
})

// checks whether appropriate banner is at the top of the site
Cypress.Commands.add('checkEnvBanner', () => {
  it('displays the dev banner', () => {
    cy.get('.govuk-phase-banner__content').should(
      'contain',
      Cypress.env('environment')
    )
  })
})

Cypress.Commands.add('checkCookieValue', (name, value) => {
  cy.getCookie(name).should('have.property', 'value', value)
})

Cypress.Commands.add('runtimeA11yCheck', (selector, rules, logCallback) => {
  cy.injectAxe()
  cy.checkA11y(selector, rules, logCallback)
})

Cypress.Commands.add('a11yLog', (violations) => {
  cy.task(
    'log',
    `${violations.length} accessibility violation${
      violations.length === 1 ? '' : 's'
    } ${violations.length === 1 ? 'was' : 'were'} detected`
  )
  // pluck specific keys to keep the table readable
  const violationData = violations.map(
    ({ id, impact, description, nodes }) => ({
      id,
      impact,
      description,
      nodes: nodes.length
    })
  )

  cy.task('table', violationData)
})
