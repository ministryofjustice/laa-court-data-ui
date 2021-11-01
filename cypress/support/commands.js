// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })

//attempts to login to vcd with given username (string) and password (strings)
Cypress.Commands.add('login', (username, password) => {
  cy.get('input#user-login-field')
    .clear()
    .type(username)
  cy.get('input#user-password-field')
    .clear()
    .type(password)
  cy.get('*[data-cy="login-submit"]')
    .click()
})

Cypress.Commands.add('dbSetup',()=>{
  cy.request('post','/cypress/create_users').then((request)=>{
    console.log(request)
  })
})