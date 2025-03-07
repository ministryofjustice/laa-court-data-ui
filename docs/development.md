# Development

## Running

To run the app locally see [Installation and running](installation.md)

## Local stack setup

For running the Court data adaptor and a Mock common platform API locally, and consuming by the user interface.

### Step-by-step:

#### Local mock common platform API setup

- clone
```
git clone git@github.com:ministryofjustice/hmcts-common-platform-mock-api.git
cd .../hmcts-common-platform-mock-api
```

- create dummy data
```
# create some data
rails mock:demodata:load
```

- start server on port 9293
```
# start server
rackup -p 9293
```

#### Local adaptor setup

- clone

```
git clone git@github.com:ministryofjustice/laa-court-data-adaptor.git
cd .../laa-court-data-adaptor
```

- configure local adaptor to use local mock common platform API, set database URL and, optionally, inline sidekiq jobs
```
# in .env.development.local
COMMON_PLATFORM_URL=http://localhost:9293
DATABASE_URL=postgres://localhost/laa_court_data_adaptor_development
INLINE_SIDEKIQ=true
```

- setup CDA database
```
# setup and seed database
rails db:setup
```
or
`rails db:create db:migrate db:seed`

- generate OAuth2 `client_credentials` - for the UI
```
rails console
> application = Doorkeeper::Application.create(name: 'LAA Court data UI')
> application.yield_self { |r| [r.uid, r.secret] }
=> [6FYXUiqrR3Yuid2ispemVNPUT7-8W0LB1sSmB6c0f3k-example, K122aTsBeRj1GuP7u-Fdi3Vm6uSKaD8K2vq0pPRocIo-example]

# These should be put in the UI's `.env.development.local` - see UI setup below
```

- start server
```
# start server
rackup -p 9292
```

#### Local UI setup

- clone
```
# clone or cd into
git clone git@github.com:ministryofjustice/laa-court-data-ui.git
cd .../laa-court-data-ui
```

- configure UI to use and authenticate against local adaptor
```
# .env.development.local
COURT_DATA_ADAPTOR_API_URL: http://localhost:9292/api/internal/v1
COURT_DATA_ADAPTOR_API_UID: uid-generated-by-adaptor-above
COURT_DATA_ADAPTOR_API_SECRET: secret-generated-by-adaptor-above
```

- start server
```
# start server
rails s
```
Note: sidekiq is configured to run jobs inline in development. See `config/initializers/sidekiq.rb`

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
