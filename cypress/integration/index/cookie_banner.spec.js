describe('Cookie banner', () => {
  before(() => {
    cy.visit('/')
    cy.checkBanner()
  })

  context('not logged in and javascript enabled', () => {
    beforeEach(() => {
      cy.visit('/')
    })

    const changeCookingSettings = 'Change your cookie settings'
    const rejectedAdditionalCookies = "You've rejected additional cookies"
    const hideMessageText = 'Hide this message'

    it('can reject cookie preferences', () => {
      cy.getCookie('cookies_preferences_set').should('not.exist')
      cy.checkCookieValue('analytics_cookies_set', 'false')
      cy.get("[data-cy='reject_cookies']")
        .should('contain', 'Reject analytics cookies')
        .and('have.attr', 'href').and('include', 'analytics_cookies_set=false&show_confirm_banner=true')

      cy.get("[data-cy='reject_cookies']").click()
      cy.get('.govuk-cookie-banner__content > p').should(
        'contain',
        rejectedAdditionalCookies
      )
      cy.checkCookieValue('cookies_preferences_set', 'true')
      cy.checkCookieValue('analytics_cookies_set', 'false')
    })

    it('can accept cookie preferences', () => {
      cy.getCookie('cookies_preferences_set').should('not.exist')
      cy.checkCookieValue('analytics_cookies_set', 'false')
      cy.get("[data-cy='accept_cookies']")
        .should('contain', 'Accept analytics cookies')
        .and('have.attr', 'href').and('include', 'analytics_cookies_set=true&show_confirm_banner=true')

      cy.get("[data-cy='accept_cookies']").click()
      cy.get('.govuk-cookie-banner__content > p').should(
        'contain',
        "You've accepted additional cookies."
      )
      cy.checkCookieValue('cookies_preferences_set', 'true')
      cy.checkCookieValue('analytics_cookies_set', 'true')
    })

    context('cookies accepted', () => {
      beforeEach(() => {
        cy.get("[data-cy='accept_cookies']")
          .should('contain', 'Accept analytics cookies')
          .and('have.attr', 'href').and('include', 'analytics_cookies_set=true&show_confirm_banner=true')
        cy.get("[data-cy='accept_cookies']").click()
      })
      const bannerMessageElement = '.govuk-cookie-banner__content > p'
      const hideMessageElement = "[data-cy='hide_message']"

      it('can hide confirmation message', () => {
        cy.get(bannerMessageElement)
          .should('contain', "You've accepted additional cookies")
        cy.get(hideMessageElement)
          .should('contain', hideMessageText)
          .and('have.attr', 'href').and('include', '?')

        cy.get(hideMessageElement).click()
        cy.get(hideMessageElement).should('not.exist')
      })

      it('can go to cookie settings from cookie banner', () => {
        cy.get(`${bannerMessageElement} > a`)
          .contains(changeCookingSettings, { matchCase: false })
          .and('have.attr', 'href').and('include', '/cookies/settings')
        cy.get(`${bannerMessageElement} > a`).click()
        cy.get('.govuk-heading-xl').should('contain', changeCookingSettings)
      })
    })

    context('cookies rejected', () => {
      beforeEach(() => {
        cy.get("[data-cy='reject_cookies']")
          .should('contain', 'Reject analytics cookies')
          .and('have.attr', 'href').and('include', 'analytics_cookies_set=false&show_confirm_banner=true')

        cy.get("[data-cy='reject_cookies']").click()
      })
      const bannerMessageElement = '.govuk-cookie-banner__content > p'
      const hideMessageElement = "[data-cy='hide_message']"

      it('can hide confirmation message', () => {
        cy.get(bannerMessageElement)
          .should('contain', rejectedAdditionalCookies)
        cy.get(hideMessageElement)
          .should('contain', hideMessageText)
          .and('have.attr', 'href').and('include', '?')

        cy.get(hideMessageElement).click()
        cy.get(hideMessageElement).should('not.exist')
      })

      it('can go to cookie settings from cookie banner', () => {
        cy.get(`${bannerMessageElement} > a`)
          .contains(changeCookingSettings, { matchCase: false })
          .and('have.attr', 'href').and('include', '/cookies/settings')
        cy.get(`${bannerMessageElement} > a`).click()
        cy.get('.govuk-heading-xl').should('contain', changeCookingSettings)
      })
    })

    it('can go to cookie settings', () => {
      cy.get("[data-cy='cookie_settings']")
        .should('contain', 'Cookie settings')
        .and('have.attr', 'href').and('include', '/cookies/settings')

      cy.get("[data-cy='cookie_settings']").click()
      cy.get('.govuk-heading-xl').should(
        'contain',
        changeCookingSettings
      )
    })
  })
})
