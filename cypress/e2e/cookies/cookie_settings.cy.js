describe('Cookie settings page', () => {
  before(() => {
    cy.clearCookies()
    cy.visit('/cookies/settings')
  })

  context('main page', () => {
    it('has no detectable a11y violations on load', () => {
      cy.customA11yCheck(null, cy.a11yLog)
    })

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
        it('has off selected as default', () => {
          cy.get('#cookie-analytics-false-field')
            .should('have.value', 'false')
            .and('be.checked')
        })
      })

      context('cookie value set to on', () => {
        beforeEach(() => {
          cy.clearCookies()
          cy.visit('/cookies/settings')
          cy.get('[data-cy="accept_cookies"]').click()
          cy.get("[data-cy='hide_message']").click()
          cy.reload()
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
          cy.customA11yCheck(null, cy.a11yLog)
        })
      })

      context('cookie value set to off', () => {
        beforeEach(() => {
          cy.clearCookies()
          cy.visit('/cookies/settings')
          cy.get('[data-cy="reject_cookies"]').click()
          cy.get("[data-cy='hide_message']").click()
          cy.reload()
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
          cy.customA11yCheck(null, cy.a11yLog)
        })
      })
    })
  })
})
