describe('User Login Page', () => {
    beforeEach(() => {
      // Cypress starts out with a blank slate for each test
      // so we must tell it to visit our website with the `cy.visit()` command.
      // Since we want to visit the same URL at the start of all our tests,
      // we include it in our beforeEach function so that it runs before each test
      cy.visit('https://dev.view-court-data.service.justice.gov.uk/')
    })

    it('displays the dev banner', () => {
        cy.get('.govuk-tag').should('have.text', "\ndev\n")
    })
})