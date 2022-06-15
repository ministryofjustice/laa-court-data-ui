/**
 * Command to allow login into the Court Data UI application
 * @param {string} username
 * @param {string} password
 * 
 */
Cypress.Commands.add("login", (username, password) => {
    cy.get("[data-cy=\"login-username\"]").clear().type(username);
    cy.get("[data-cy=\"login-password\"]").clear().type(password);
    cy.get("[data-cy=\"login-submit\"]").click();
});