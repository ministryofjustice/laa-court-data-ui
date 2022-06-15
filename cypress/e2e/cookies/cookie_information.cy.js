describe('Cookie Information Page', () => {
    before(() => {
        cy.visit('/cookies')
    })

    context('main page', () => {
        it('displays the title', () => {
            cy.get('.govuk-heading-xl')
                .should('contain', 'Cookies on View Court Data')
        })

        context('necessary cookie information', () => {
            it('displays the title', () => {
                cy.get('[data-cy="necessary-cookies"]')
                    .should('contain', 'Strictly necessary cookies')
            })

            it('shows session cookie information', () => {
                cy.get('[data-cy="session-cookie-name"')
                    .should('contain', '_laa_court_data_ui_session')
                cy.get('[data-cy="session-cookie-purpose"')
                    .should('contain', 'Remembers you as you use the service.')
                cy.get('[data-cy="session-cookie-expires"')
                    .should('contain', 'At the end of the session')
            })
        })

        context('acceptance cookie information', () => {
            it('displays the title', () => {
                cy.get('[data-cy="settings-cookies"]')
                    .should('contain', 'Cookies that remember your settings')
            })

            it('shows analytics cookie information', () => {
                cy.get('[data-cy="analytics-cookie-name"')
                    .should('contain', 'analytics_cookies_set')
                cy.get('[data-cy="analytics-cookie-purpose"')
                    .should('contain', 'Remembers whether you have given permission for us to use analytics cookies.')
                cy.get('[data-cy="analytics-cookie-expires"')
                    .should('contain', '1 year')
            })

            it('shows preferences cookie information', () => {
                cy.get('[data-cy="preferences-cookie-name"')
                    .should('contain', 'cookies_preferences_set')
                cy.get('[data-cy="preferences-cookie-purpose"')
                    .should('contain', 'Used to remember whether the cookie banner has been displayed.')
                cy.get('[data-cy="preferences-cookie-expires"')
                    .should('contain', '1 year')
            })

            it('shows remember me cookie information', () => {
                cy.get('[data-cy="rememberme-cookie-name"')
                    .should('contain', 'remember_user_token')
                cy.get('[data-cy="rememberme-cookie-purpose"')
                    .should('contain', 'Selected at log on, remembers you for next time.')
                cy.get('[data-cy="rememberme-cookie-expires"')
                    .should('contain', '1 fortnight')
            })
        })

        context('GA cookie information', () => {
            it('displays the title', () => {
                cy.get('[data-cy="ga-cookies"]')
                    .should('contain', 'Cookies that measure website use')
            })

            it('shows ga cookie information', () => {
                cy.get('[data-cy="ga-cookie-name"')
                    .should('contain', '_ga')
                cy.get('[data-cy="ga-cookie-purpose"')
                    .should('contain', 'These help us count how many people visit the service by tracking if you have visited before.')
                cy.get('[data-cy="ga-cookie-expires"')
                    .should('contain', '2 years')
            })

            it('shows gat cookie information', () => {
                cy.get('[data-cy="gat-cookie-name"')
                    .should('contain', '_gat')
                cy.get('[data-cy="gat-cookie-purpose"')
                    .should('contain', 'Used to manage the rate at which page view requests are made.')
                cy.get('[data-cy="gat-cookie-expires"')
                    .should('contain', '1 minute')
            })

            it('shows gid cookie information', () => {
                cy.get('[data-cy="gid-cookie-name"')
                    .should('contain', '_gid')
                cy.get('[data-cy="gid-cookie-purpose"')
                    .should('contain', 'These help us count how many people visit the service by tracking if you have visited before.')
                cy.get('[data-cy="gid-cookie-expires"')
                    .should('contain', '24 hours')
            })
        })

        context('Cookie link', () => {
            it('displays the title', () => {
                cy.get('[data-cy="change-cookies"]')
                    .should('contain', 'Change your cookie settings')
            })

            it('has a hyperlink to change the settings', () => {
                cy.get('[data-cy="cookie-settings-hyperlink"]')
                    .should('have.attr', 'href')
                    .and('include', '/cookies/settings')
            })            
            
            it('navigates to the correct page', () => {
                cy.get('[data-cy="cookie-settings-hyperlink"]').click()
                cy.location('pathname').should('eq', '/cookies/settings')
            })
        })
    })



})