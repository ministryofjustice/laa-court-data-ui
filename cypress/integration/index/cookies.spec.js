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

    it('can reject cookie preferences', () => {
      cy.getCookie('cookies_preferences_set').should('not.exist')
      cy.checkCookieValue('analytics_cookies_set', 'false')
      cy.get("[data-cy='reject_cookies']")
        .should('contain', 'Reject analytics cookies')
        .should('have.attr', 'href').and('include', 'analytics_cookies_set=false&show_confirm_banner=true')

      cy.get(".app-js-only > [data-cy='reject_cookies']").click()
      cy.get('.govuk-cookie-banner__content > p').should(
        'contain',
        "You've rejected additional cookies."
      )
      cy.checkCookieValue('cookies_preferences_set', 'true')
      cy.checkCookieValue('analytics_cookies_set', 'false')
    })

    it('can accept cookie preferences', () => {
      cy.getCookie('cookies_preferences_set').should('not.exist')
      cy.checkCookieValue('analytics_cookies_set', 'false')
      cy.get("[data-cy='accept_cookies']")
        .should('contain', 'Accept analytics cookies')
        .should('have.attr', 'href').and('include', 'analytics_cookies_set=true&show_confirm_banner=true')

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
          .should('have.attr', 'href').and('include', 'analytics_cookies_set=true&show_confirm_banner=true')
        cy.get("[data-cy='accept_cookies']").click()
      })
      const bannerMessageElement = '.govuk-cookie-banner__content > p'
      const hideMessageElement = "[data-cy='hide_message']"

      it('can hide confirmation message', () => {
        cy.get(`${bannerMessageElement}`)
          .should('contain', "You've accepted additional cookies")
        cy.get(`${hideMessageElement}`)
          .should('contain', 'Hide this message')
          .should('have.attr', 'href').and('include', '?')

        cy.get(`${hideMessageElement}`).click()
        cy.get(`${hideMessageElement}`).should('not.exist')
      })

      it('can go to cookie settings from cookie banner', () => {
        cy.get(`${bannerMessageElement} > a`)
          .should('contain', 'change your cookie settings')
          .should('have.attr', 'href').and('include', '/cookies/settings')
        cy.get(`${bannerMessageElement} > a`).click()
        cy.get('.govuk-heading-xl').should('contain', 'Change your cookie settings')
      })
    })

    context('cookies rejected', () => {
      beforeEach(() => {
        cy.get("[data-cy='reject_cookies']")
          .should('contain', 'Reject analytics cookies')
          .should('have.attr', 'href').and('include', 'analytics_cookies_set=false&show_confirm_banner=true')

        cy.get("[data-cy='reject_cookies']").click()
      })
      const bannerMessageElement = '.govuk-cookie-banner__content > p'
      const hideMessageElement = "[data-cy='hide_message']"

      it('can hide confirmation message', () => {
        cy.get(`${bannerMessageElement}`)
          .should('contain', "You've rejected additional cookies")
        cy.get(`${hideMessageElement}`)
          .should('contain', 'Hide this message')
          .should('have.attr', 'href').and('include', '?')

        cy.get(`${hideMessageElement}`).click()
        cy.get(`${hideMessageElement}`).should('not.exist')
      })

      it('can go to cookie settings from cookie banner', () => {
        cy.get(`${bannerMessageElement} > a`)
          .should('contain', 'change your cookie settings')
          .should('have.attr', 'href').and('include', '/cookies/settings')
        cy.get(`${bannerMessageElement} > a`).click()
        cy.get('.govuk-heading-xl').should('contain', 'Change your cookie settings')
      })
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
  beforeEach(() => {
    cy.visit('/')
    cy.get("[data-cy='cookie_settings']")
      .should('contain', 'Cookie settings')
      .should('have.attr', 'href').and('include', '/cookies/settings')

    cy.get(".app-js-only > [data-cy='cookie_settings']").click()
  })

  context('Cookies storing is set as false', () => {
    beforeEach(() => {
      cy.getCookie('cookies_preferences_set').should('not.exist')
      cy.checkCookieValue('analytics_cookies_set', 'false')

      cy.get(".app-js-only > [data-cy='cookie_settings']").click()
    })

    it('can change cookie settings', () => {
      cy.get('input#cookie-analytics-true-field').should('have.value', 'true')
      cy.get('input#cookie-analytics-true-field').check()
      cy.get("[data-cy='submit-cookies']").click()
      cy.get('.govuk-notification-banner__heading').should('contain', "You've set your cookie preferences.")
      cy.checkCookieValue('cookies_preferences_set', 'true')
      cy.checkCookieValue('analytics_cookies_set', 'true')
    })
  })

  context('Cookies storing is set as true', () => {
    beforeEach(() => {
      cy.visit('/')
      cy.get(".app-js-only > [data-cy='cookie_settings']").click()
      cy.setCookie('cookies_preferences_set', 'true')
      cy.setCookie('analytics_cookies_set', 'true')
    })

    it('can change cookie settings', () => {
      cy.get('input#cookie-analytics-false-field').should('have.value', 'false')
      cy.get('input#cookie-analytics-false-field').check()
      cy.get("[data-cy='submit-cookies']").click()
      cy.get('.govuk-notification-banner__heading').should('contain', "You've set your cookie preferences.")
      cy.checkCookieValue('cookies_preferences_set', 'true')
      cy.checkCookieValue('analytics_cookies_set', 'false')
    })
  })
})
