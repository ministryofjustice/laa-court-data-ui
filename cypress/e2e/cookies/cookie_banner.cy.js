const acceptedAdditionalCookies = 'You\'ve accepted additional cookies.'
const rejectedAdditionalCookies = 'You\'ve rejected additional cookies'
const hideMessageText = 'Hide this message'

describe('Cookie banner', () => {
  context('cookie value is not set', () => {
    context('reject cookies', () => {
      beforeEach(() => {
        cy.visit('/')
      })

      it('has no detectable a11y violations on load', () => {
        cy.customA11yCheck(null, cy.a11yLog)
      })

      it('can reject the cookie preferences', () => {
        cy.getCookie('cookies_preferences_set').should('not.exist')
        cy.get('[data-cy="reject_cookies"]')
          .should('contain', 'Reject analytics cookies')
          .and('have.attr', 'href')
          .and('include', 'analytics_cookies_set=false&show_confirm_banner=true')
        cy.get('[data-cy="reject_cookies"]').click()
        cy.customA11yCheck(null, cy.a11yLog)
        cy.get('.govuk-cookie-banner__content > p').should('contain', rejectedAdditionalCookies)
        cy.getCookie('cookies_preferences_set').should('have.property', 'value', 'true')
        cy.getCookie('analytics_cookies_set').should('have.property', 'value', 'false')
      })

      it('can hide the banner', () => {
        cy.get('[data-cy="reject_cookies"]').click()
        cy.get('.govuk-cookie-banner__content > p').should('contain', rejectedAdditionalCookies)
        cy.get("[data-cy='hide_message']")
          .should('contain', hideMessageText)
          .and('have.attr', 'href')
          .and('include', '?')

        cy.get("[data-cy='hide_message']").click()
        cy.get('.app-cookie-banner').should('not.exist')
        cy.get("[data-cy='hide_message']").should('not.exist')
        cy.customA11yCheck(null, cy.a11yLog)
      })
    })

    context('accept cookies', () => {
      beforeEach(() => {
        cy.visit('/')
      })
      it('can accept the cookie preferences', () => {
        cy.getCookie('cookies_preferences_set').should('not.exist')
        cy.get('[data-cy="accept_cookies"]')
          .should('contain', 'Accept analytics cookies')
          .and('have.attr', 'href')
          .and('include', 'analytics_cookies_set=true&show_confirm_banner=true')
        cy.get('[data-cy="accept_cookies"]').click()
        cy.customA11yCheck(null, cy.a11yLog)
        cy.get('.govuk-cookie-banner__content > p').should('contain', acceptedAdditionalCookies)
        cy.getCookie('cookies_preferences_set').should('have.property', 'value', 'true')
        cy.getCookie('analytics_cookies_set').should('have.property', 'value', 'true')
      })

      it('can hide the banner', () => {
        cy.get('[data-cy="accept_cookies"]').click()
        cy.get('.govuk-cookie-banner__content > p').should('contain', acceptedAdditionalCookies)
        cy.get("[data-cy='hide_message']")
          .should('contain', hideMessageText)
          .and('have.attr', 'href')
          .and('include', '?')

        cy.get("[data-cy='hide_message']").click()
        cy.get('.app-cookie-banner').should('not.exist')
        cy.get("[data-cy='hide_message']").should('not.exist')
        cy.customA11yCheck(null, cy.a11yLog)
      })
    })
  })

  context('cookie value is set', () => {
    before(() => {
      cy.visit('/')
      cy.setCookie('cookies_preferences_set', 'true')
      cy.reload()
    })

    it('does not display the banner', () => {
      cy.get('.app-cookie-banner').should('not.exist')
      cy.customA11yCheck(null, cy.a11yLog)
    })
  })
})
