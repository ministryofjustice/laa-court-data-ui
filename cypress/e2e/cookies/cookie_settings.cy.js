describe('Cookie settings page', () => {
  beforeEach(() => {
    cy.visit('/cookies/settings')
  })

  context('main page', () => {
    it('displays the title', () => {
      cy.get('.govuk-heading-xl')
        .should('contain', 'Change your cookie settings')
    })

    context('necessary cookie information', () => {
      it('displays the title', () => {
        cy.get('[data-cy="necessary-cookies"]')
          .should('contain', 'Strictly necessary cookies')
      })

      it('has a hyperlink to change the settings', () => {
        cy.get('[data-cy="cookie-hyperlink"]')
          .should('have.attr', 'href')
          .and('include', '/cookies')
      })

      it('navigates to the correct page', () => {
        cy.get('[data-cy="cookie-hyperlink"]').click()
        cy.location('pathname').should('eq', '/cookies')
      })
    })

    context('cookie settings', () => {
      it('displays the title', () => {
        cy.get('[data-cy="cookie-settings"]')
          .should('contain', 'Cookie settings')
      })

      context('cookie value not set', () => {
        before(() => {
          cy.clearCookie('analytics_cookies_set')
        })

        it('has off selected as default', () => {
          cy.get('#cookie-analytics-false-field')
            .should('have.value', 'false')
            .and('be.checked')
        })
      })

      context('cookie value set to off', () => {
        before(() => {
          cy.setCookie('analytics_cookies_set', 'false')
        })

        it('has off selected', () => {
          cy.get('#cookie-analytics-false-field')
            .should('have.value', 'false')
            .and('be.checked')
        })

        it('can update the value to on', () => {
          cy.get('#cookie-analytics-true-field').check()
          cy.get('[data-cy="submit-cookies"]').click()
          cy.get('.govuk-notification-banner__heading').should('contain', 'You\'ve set your cookie preferences.')
          cy.getCookie('analytics_cookies_set', 'true')
        })
      })

      context('cookie value set to on', () => {
        before(() => {
          cy.setCookie('analytics_cookies_set', 'true')
        })

        it('has on selected', () => {
          cy.get('#cookie-analytics-true-field')
            .should('have.value', 'true')
            .and('be.checked')
        })

        it('can update the value to off', () => {
          cy.get('#cookie-analytics-false-field').check()
          cy.get('[data-cy="submit-cookies"]').click()
          cy.get('.govuk-notification-banner__heading').should('contain', 'You\'ve set your cookie preferences.')
          cy.getCookie('analytics_cookies_set', 'false')
        })
      })
    })
  })
})
