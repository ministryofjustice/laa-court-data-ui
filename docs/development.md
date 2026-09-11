# Development

## Running

To run the app locally see [Installation and running](installation.md)

## Local stack setup

These instructions assume the following:

- You have the [`laa-court-data-adaptor`](https://github.com/ministryofjustice/laa-court-data-adaptor) repository cloned in a sibling directory to this repository.
- You are [already setup on the MoJ Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html).

If you want to run the whole stack, including the adaptor and hot reloading for the UI and adaptor, you can use the
following command:

```
make run_all
```

This will do the following:

- Build the necessary containers for the adaptor and the UI.
- Create environment variables for the UI by generating a UID and secret for the adaptor API.
- Create environment variables for the adaptor by reading the Kubenetes secrets from Cloud Platform to connect to the
  [Common Platform Mock API](https://github.com/ministryofjustice/hmcts-common-platform-mock-api) and the development
  instance of the [MAAT Court Data API](https://github.com/ministryofjustice/laa-maat-court-data-api)
- Set up the databases for the adaptor and the UI, and run any seeds and migrations.
- Run all the containers in development mode.

You will then be able to access the UI at `http://localhost:3000` and the adaptor at `http://localhost:3001`.

## Development notes

### A note on initial app generation

This app was generated using the following initial `rails new` command, skipping all components we do not currently need.

```
# generate new rails app
rails new laa-court-data-ui \
--database=postgresql \
--skip-test \
--skip-action-mailer \
--skip-active-storage \
--skip-action-cable \
--skip-turbolinks \
--skip-sprockets
```

Note: The govuk styling was applied following the [GDS design system guide](https://github.com/alphagov/govuk-frontend/blob/master/docs/installation/installing-with-npm.md), using `npm install --save govuk-frontend`. `yarn`
was later used to manage js dependencies. It may have been possible to use
`yarn` from the outset

### A note on Ruby 2.7 deprecation warnings

There are a lot of warnings related to ruby 2.7 and rails 6.0.2.1. These are largely related to use of keyword arguments, such as below, and should be fixed
in rails patches in the future:
```
..action_dispatch/middleware/stack.rb:37: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
```

To suppress warnings now you can prefix any call that raises such warnings with `RUBYOPT=-W:no-deprecated`:
```
RUBYOPT=-W:no-deprecated rspec
RUBYOPT=-W:no-deprecated rails server
RUBYOPT=-W:no-deprecated rails console
```

Alternatively there is an `.env` file in the root app to set this generally
```
source .env
```

### A note on assets

The rails asset pipeline is disabled and all related config is commented out (it does not seem possible to remove sprockets entirely). We are using `jsbundling-rails` gem wrapper for compiling and building asset dependencies, and `yarn` for node.js dependency management.

### Secret management

Secrets should _not_ be kept in this repository. In the past `git-crypt` has been used to encrypt secrets within the repo however due to the difficulty of rotating the symmetric key used for encryption following a security breach, this approach has now been deprecated.

Secrets are held as Kubernetes Secret objects in the cluster. These can be accessed by executing

```bash
kubectl -n laa-court-data-ui-<env> get secrets
```

when authenticated to the cluster to view a list of all secrets.

To view the contents of a Secret, execute:

```bash
kubectl -n laa-court-data-ui-<env> get secrets <secret-name> -o json
```

For more details on how to add or update Kubernetes Secrets, see the [Cloud Platform documentation](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/add-secrets-to-deployment.html#adding-a-secret-to-an-application).

Secrets are backed up outside of Kubernetes, these back ups need to be updated any time the secrets are updated. Please refer to this [Confluence document](https://dsdmoj.atlassian.net/wiki/spaces/CFP/pages/4273504650/Secrets+Strategy+Post+Git-Crypt#Where-We-Are-Storing-Secrets-Now) for more information
