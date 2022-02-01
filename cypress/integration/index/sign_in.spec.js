// Define at the top of the spec file or just import it
function terminalLog(violations) {
  cy.task(
    "log",
    `${violations.length} accessibility violation${
      violations.length === 1 ? "" : "s"
    } ${violations.length === 1 ? "was" : "were"} detected`
  );
  // pluck specific keys to keep the table readable
  const violationData = violations.map(
    ({ id, impact, description, nodes }) => ({
      id,
      impact,
      description,
      nodes: nodes.length,
    })
  );

  cy.task("table", violationData);
}

describe("User Login Page", () => {
  before(() => {
    cy.visit("/");
    cy.checkEnvBanner();
  });

  beforeEach(() => {
    cy.visit("/");
    cy.injectAxe();
  });

  it("Has no detectable a11y violations on load", () => {
    // Test the page at initial load
    cy.checkA11y(null, null, terminalLog);
  });

  it("displays the login page", () => {
    cy.get(".govuk-heading-xl").should("have.text", "Sign in");
    cy.get("#new_user")
      .should("contain", "Username or email")
      .and("contain", "Password");
    cy.get("input#user-login-field").should("exist");
    cy.get("input#user-password-field").should("exist");
  });

  it("can log in with correct credentials", () => {
    cy.fixture("users").then((users) => {
      cy.login(users[0].username, users[0].password);
      cy.get(".govuk-error-summary__title").should(
        "contain",
        "Signed in successfully."
      );
    });
  });

  it("cannot log in with incorrect credentials", () => {
    cy.login("someone", "some-password");
    cy.get(".govuk-error-summary__title").should(
      "contain",
      "Invalid username or password."
    );
  });

  it("can log in with valid credentials after an invalid attempt", () => {
    cy.login("invalid-username", "invalid-password");
    cy.get(".govuk-error-summary__title").should(
      "contain",
      "Invalid username or password."
    );
    cy.fixture("users").then((users) => {
      cy.login(users[0].username, users[0].password);
      cy.get(".govuk-error-summary__title").should(
        "contain",
        "Signed in successfully."
      );
    });
  });

  context("logged in", () => {
    beforeEach(() => {
      cy.visit("/");
      cy.fixture("users").then((users) => {
        cy.login(users[0].username, users[0].password);
      });
    });

    it("displays search filters page", () => {
      cy.get(".govuk-fieldset__legend").should("contain", "Search for");
    });

    it("can log out", () => {
      cy.get("[data-method='delete']")
        .should("have.text", "Sign out")
        .should("have.attr", "href")
        .and("include", "/users/sign_out");

      cy.get("[data-method='delete']").click();
      cy.get(".govuk-error-summary__title").should(
        "contain",
        "Signed out successfully."
      );
    });
  });

  context("logged out", () => {
    it("can not see search filters", () => {
      cy.get("#main-content").not("contain", "Search for");
    });
  });
});
