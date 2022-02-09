describe("Cookie settings page", () => {
	const successfullySetCookies = "You've set your cookie preferences.";

	context("not logged in and javascript enabled", () => {
		beforeEach(() => {
			cy.visit("/");
			cy.get("[data-cy='cookie_settings']")
				.should("contain", "Cookie settings")
				.should("have.attr", "href")
				.and("include", "/cookies/settings");
			cy.get("[data-cy='cookie_settings']").click();
		});

		it("has no detectable a11y violations on load", () => {
			cy.customA11yCheck(null, cy.a11yLog);
		});

		context("Cookies storing is set as false", () => {
			beforeEach(() => {
				cy.getCookie("cookies_preferences_set").should("not.exist");
				cy.checkCookieValue("analytics_cookies_set", "false");
				cy.get("[data-cy='cookie_settings']").click();
			});

			it("can change cookie settings", () => {
				cy.get("input#cookie-analytics-true-field").should(
					"have.value",
					"true"
				);
				cy.get("input#cookie-analytics-true-field").check();
				cy.get("[data-cy='submit-cookies']").click();
				cy.customA11yCheck(null, cy.a11yLog);
				cy.get(".govuk-notification-banner__heading").should(
					"contain",
					successfullySetCookies
				);
				cy.checkCookieValue("cookies_preferences_set", "true");
				cy.checkCookieValue("analytics_cookies_set", "true");
			});
		});

		context("Cookies storing is set as true", () => {
			beforeEach(() => {
				cy.visit("/");
				cy.get("[data-cy='cookie_settings']").click();
				cy.setCookie("cookies_preferences_set", "true");
				cy.setCookie("analytics_cookies_set", "true");
			});

			it("can change cookie settings", () => {
				cy.get("input#cookie-analytics-false-field").should(
					"have.value",
					"false"
				);
				cy.get("input#cookie-analytics-false-field").check();
				cy.get("[data-cy='submit-cookies']").click();
				cy.customA11yCheck(null, cy.a11yLog);
				cy.get(".govuk-notification-banner__heading").should(
					"contain",
					successfullySetCookies
				);
				cy.checkCookieValue("cookies_preferences_set", "true");
				cy.checkCookieValue("analytics_cookies_set", "false");
			});
		});
	});
});
