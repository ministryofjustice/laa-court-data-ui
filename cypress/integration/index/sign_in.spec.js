describe("User Login Page", () => {
  before(() => {
    cy.visit("/");
    cy.checkBanner();
  });

  beforeEach(() => {
    cy.visit("/");
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
    cy.login("someone", "some-password");
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
});
