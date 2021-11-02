// attempts to login to vcd with given username (string) and password (strings)
Cypress.Commands.add('login', (username, password) => {
  cy.get('input#user-login-field')
    .clear()
    .type(username)
  cy.get('input#user-password-field')
    .clear()
    .type(password)
  cy.get('*[data-cy="login-submit"]')
    .click()
})

// checks whether appropriate banner is at the top of the site
Cypress.Commands.add('checkBanner', () => {
  it('displays the dev banner', () => {
    cy.get('.govuk-phase-banner__content').should('contain', Cypress.env('environment'))
  })
})
