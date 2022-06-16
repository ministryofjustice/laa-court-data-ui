/**
 * Command to allow login into the Court Data UI application
 * @param {string} username
 * @param {string} password
 *
 */
Cypress.Commands.add('login', (username, password) => {
  cy.get('[data-cy="login-username"]').clear().type(username)
  cy.get('[data-cy="login-password"]').clear().type(password)
  cy.get('[data-cy="login-submit"]').click()
})

Cypress.Commands.add('customA11yCheck', (selector, logCallback) => {
  const options = {
    includedImpacts: ['critical', 'serious']
  }
  cy.injectAxe()
  cy.checkA11y(selector, options, logCallback)
})

Cypress.Commands.add('a11yLog', (violations) => {
  cy.task(
    'log',
    `${violations.length} accessibility violation${violations.length === 1 ? '' : 's'
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
