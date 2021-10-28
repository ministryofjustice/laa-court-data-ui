describe('User Login Page', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('displays the dev banner', () => {
    cy.get('.govuk-phase-banner__content').should('contain', Cypress.env('environment'))
  })

  it('displays the login page', () => {
    cy.get('.govuk-heading-xl').should('have.text', 'Sign in')
    cy.get('#new_user')
      .should('contain', 'Username or email')
      .and('contain', 'Password')
    cy.get('input#user-login-field').should('exist')
    cy.get('input#user-password-field').should('exist')
  })

  it('can log in with correct credentials', () => {
    cy.fixture('users').then((users) => {
      cy.login(users.caseworker.username, users.caseworker.password)
      cy.get('.govuk-error-summary__title')
        .should('contain', 'Signed in successfully.')
    })
  })

  it('cannot log in with incorrect credentials', () => {
    cy.login('someone', 'some-password')
    cy.get('.govuk-error-summary__title')
      .should('contain', 'Invalid username or password.')
  })
})
