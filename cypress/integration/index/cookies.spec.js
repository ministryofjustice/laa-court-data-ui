describe('Cookie banner', () => {
  before(() => {
    cy.visit('/')
    cy.checkBanner()
  })

  context('logged in with javascript enabled', () => {
    beforeEach(() => {
      cy.visit('/')
      cy.fixture('users').then((users) => {
        cy.login(users[0].username, users[0].password)
      })
    })

    it('displays search filters page', () => {
      cy.get('.govuk-fieldset__legend').should(
        'contain',
        'Search for'
      )
    })

    it('can accept cookie preferences', () => {
      cy.get("[data-cy='accept_cookies']")
        .should('contain', 'Accept analytics cookies')
        .should('have.attr', 'href').and('include', 'analytics_cookies_set=true&show_confirm_banner=true')

      cy.get("[data-cy='accept_cookies']").click()
      cy.get('.govuk-cookie-banner__content > p').should(
        'contain',
        "You've accepted additional cookies."
      )
    })

    it('can reject cookie preferences', () => {
      cy.get("[data-cy='reject_cookies']")
        .should('contain', 'Reject analytics cookies')
        .should('have.attr', 'href').and('include', 'analytics_cookies_set=false&show_confirm_banner=true')

      cy.get(".app-js-only > [data-cy='reject_cookies']").click()
      cy.get('.govuk-cookie-banner__content > p').should(
        'contain',
        "You've rejected additional cookies."
      )
    })

    it('can go to cookie settings', () => {
      cy.get("[data-cy='cookie_settings']")
        .should('contain', 'Cookie settings')
        .should('have.attr', 'href').and('include', '/cookies/settings')

      cy.get(".app-js-only > [data-cy='cookie_settings']").click()
      cy.get('.govuk-heading-xl').should(
        'contain',
        'Change your cookie settings'
      )
    })
  })
})

describe('Cookie settings', () => {
  before(() => {
    cy.visit('/')
    cy.get("[data-cy='cookie_settings']")
      .should('contain', 'Cookie settings')
      .should('have.attr', 'href').and('include', '/cookies/settings')

    cy.get(".app-js-only > [data-cy='cookie_settings']").click()
  })

  it('can submit updated cookie settings', () => {
    cy.get('input#cookie-analytics-true-field').should('have.value', 'true')
    cy.get('input#cookie-analytics-true-field').check()

    cy.get("[data-cy='submit-cookies']").click()
  })
})
