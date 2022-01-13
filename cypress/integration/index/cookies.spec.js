describe("Cookie banner", () => {
    before(() => {
      cy.visit("/");
      cy.checkBanner();
    });

    context('logged in with javascript enabled', () => {
      beforeEach(() => {
				cy.visit("/");
				cy.fixture("users").then((users) => {
					cy.login(users[0].username, users[0].password);
				});
      });

      it('displays search filters page', () => {
        cy.get(".govuk-fieldset__legend").should(
            "contain",
            "Search for"
        );
      });

      it('can accept cookie preferences', () => {
        cy.get('[data-accept-cookies="true"]')
						.should("contain", "Accept analytics cookies")
            .should('have.attr', 'href').and('include', "analytics_cookies_set=true&show_confirm_banner=true");

        cy.get('[data-accept-cookies="true"]').click();
        cy.get('.govuk-cookie-banner__content > p').should(
            "contain",
            "You've accepted additional cookies."
        );
      });

      it('can reject cookie preferences', () => {
        cy.get('[data-reject-cookies="true"]')
						.should("contain", "Reject analytics cookies")
            .should('have.attr', 'href').and('include', "analytics_cookies_set=false&show_confirm_banner=true");

        cy.get('.app-js-only > [data-reject-cookies="true"]').click();
        cy.get('.govuk-cookie-banner__content > p').should(
            "contain",
            "You've rejected additional cookies."
        );
      });

			it('can go to cookie settings', () => {
				cy.get('.govuk-link')
				.should("contain", "Cookie settings")
				.should('have.attr', 'href').and('include', "/cookies/settings");

				cy.get('.app-js-only > .govuk-link').click();
        cy.get('.govuk-heading-xl').should(
            "contain",
            "Change your cookie settings"
        );
			});
  });
});

describe("Cookie settings", () => {
	before(() => {
		cy.visit("/");
		cy.get('.govuk-link')
		.should("contain", "Cookie settings")
		.should('have.attr', 'href').and('include', "/cookies/settings");

		cy.get('.app-js-only > .govuk-link').click();
	});


	it('can update cookie settings', () => {
		cy.get('input#cookie-analytics-true-field')
		.should("have.value", "true");

		cy.get('input#cookie-analytics-true-field').check();
		Cypress.on('uncaught:exception', (err, runnable) => {
			// returning false here prevents Cypress from
			// failing the test due to TypeError: Illegal Invocation in Rails ujs nodemodule
			return false
		});
	
		cy.get('form.app-js-only#new_cookie').submit();
		
	});
});