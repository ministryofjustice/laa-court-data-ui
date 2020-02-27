# Court data UI (a.k.a View court data)
An interace to the [laa-court-data-adaptor](https://github.com/ministryofjustice/laa-court-data-adaptor) for displaying information available from the HMCTS "common platform" API.

[![Code Climate](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui/coverage)

## System dependencies
- postgres
- ruby 2.7.0+
- rails 6.0.2.1+
- nvm
- node 12.4.1+
- yarn 1.21.1+


## Quick start (on macosx)
```
make install

# in separate terminal
make run

make open
```

## Setup

Clone:
```
# clone
git clone https://github.com/ministryofjustice/laa-court-data-ui
cd laa-court-data-ui
```

Install on MacOSX:
```
# check ./Makefile for individual installation steps
make install
```

Install app dependencies (step-by-step):
```
# install ruby if required
rvm install $(cat .ruby-version)

# install gems
bundle install

# install node (using projects version `.nvmrc`)
nvm install

# install node modules using yarn
yarn install --frozen-lockfile

# setup database
rails db:setup
rails db:migrate
rails db:seed
```

## Assets
The rails asset pipeline is disabled and all related config is commented out (it does not seem possible to remove sprockets entirely). We are using `webpacker` gem wrapper for `webpack`, and `yarn` for js dependency management.

To run app locally (development mode) you will therefore need to run both the `rails server` and the `webpack-dev-server` (for asset serving). see [Development](#Development)

## Development

To run the app locally you can generally use just `rails server`, however optional components can be run depending on your needs.

Run separate servers per terminal
```
# terminal-1
rails server

# terminal-2 (assets server - this may not be needed?!)
bin/webpack-dev-server

# terminal-3 (fake adaptor API - see below)
rackup lib/fake_court_data_adaptor/config.ru
```

or using a single terminal and foreman and includes fake API server
```
foreman start -f Procfile.dev

# alternative, runs above command
make run
```

## Testing

#### Ruby 2.7 deprecation warnings
There are a lot of warnings related to ruby 2.7 and rails 6.0.2.1. These are largely related to use of keyword arguments, such as below, and should be fixed
in rails patches in the future:
```
..action_dispatch/middleware/stack.rb:37: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
```

To suppress warnings now you can prefix any call that raises such warnings with `RUBYOPT=-W:no-deprecated`:
```
RUBYOPT=-W:no-deprecated rspec
RUBYOPT=-W:no-deprecated rails server
```


## Makefile
You can use the `make` command as follows:

```
# get help - check what make commands are available
make

# simple first install (assuming you have `rvm` and `nvm` installed)
make install

#run the app
make run

# run the entire test suite
make test
```

## Local stack setup

For running the Court data adaptor and a Mock common platform API locally, and consuming by the user interface.

Step-by-step:

#### Local mock common platform API setup

- clone
```
git clone git@github.com:ministryofjustice/hmcts-common-platform-mock-api.git
cd .../hmcts-common-platform-mock-api
```

- create dummy data
```
# create some data
$ rails console
Pry> FactoryBot.create(:realistic_prosecution_case, defendants: FactoryBot.create_list(:realistic_defendant, 3))
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

- generate OAuth2 `client_credentials` - for the UI
```
rails console
> application = Doorkeeper::Application.create(name: 'LAA Court data UI')
> application.yield_self { |r| [r.uid, r.secret] }
=> [6FYXUiqrR3Yuid2ispemVNPUT7-8W0LB1sSmB6c0f3k-example, K122aTsBeRj1GuP7u-Fdi3Vm6uSKaD8K2vq0pPRocIo-example]

# These should be put in the UI's `.env.development.local` - see UI setup below
```

- configure adaptor to use local mock common platform API
```
# in .env.development.local
COMMON_PLATFORM_URL=http://localhost:9293
SHARED_SECRET_KEY_LAA_REFERENCE=super-secret-search-laa-reference-key
SHARED_SECRET_KEY_REPRESENTATION_ORDER=super-secret-search-representation-order-key
SHARED_SECRET_KEY_SEARCH_PROSECUTION_CASE=super-secret-search-prosecution-case-key
SHARED_SECRET_KEY_HEARING=super-secret-hearing-key
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
COURT_DATA_ADAPTOR_API_URL: http://localhost:9292
COURT_DATA_ADAPTOR_API_UID: uid-generated-by-adaptor-above
COURT_DATA_ADAPTOR_API_SECRET: secret-generated-by-adaptor-above
```

- start server
```
# start server
rails s
```

## Fake API calling

For development purposes a fake "Court Data Adaptor" API has been provided. This can be used to view
search results in development. The fake API will need updating or removing in future iterations.

To enable the fake API you must:

- set/amend environment variable to point to it
```
# .env.development
COURT_DATA_ADAPTOR_HOST: http://localhost:9292
```

- run the fake API using either of the methods below


```
# run in its own console - uses puma
rackup lib/fake_court_data_adaptor/config.ru
```

```
# run along with app
make run
```

Note, running two puma servers requires that they use separate pid files. The fake api is therefore configured to use tmp/pids/fake_adaptor.pid via its `config.ru`. Bear this in mind if amending the `config/puma/development.rb` files `pidfile` entry, to prevent clashes.

#### VCR and Webmock

- Strategy

  OAuth2 access token requests should be ignored by VCR to avoid problems with loading of adaptor client. Instead the client is configured to not attempt to retrieve an access token from the adaptor when in `test_mode`. To record new cassettes therefore requires you to switch `test_mode` off.


- Creating new cassettes

  - check you can successfully query the adaptor

    You should be able to to retrieve the results you expect against a locally running version of the adaptor, or a hosted one. see the instructions on [local stack setup](#local-stack-setup)

  - setup an `.env.test.local`

    The adaptor used can be running locally or be one of the actual hosted envs for the adaptor, but in either case the uid and secret must be valid for that adaptor API.

    **use `.env.test.local` not `.env.test` to ensure you do not commit/push actual uid and secret to github**

    ```
    # .env.test.local
    COURT_DATA_ADAPTOR_API_URL: http://localhost:9292/api/internal/v1
    COURT_DATA_ADAPTOR_API_UID: uid-from-api-host-above
    COURT_DATA_ADAPTOR_API_SECRET: secret-from-api-host-above
    ```

  - add app's default VCR cassette recording options

    The test for which you wish to record a VCR cassette should have a `vcr: true` (or just `:vcr`) option on its block, as below. Nested blocks inherit this behaviour.

    ```
    describe MyClass, :vcr do
      it { expect(foo).to eql 'bar' }
    end
    ```

    *This calls an `around` rspec hook which records `new_episodes` in a cassette named after the full path of the spec.*

  - turn test mode off

    Test mode needs turning off to enable actual authentication requests to the adaptor. This can be achieved by amending an ENV var. This is necessary since you will be submitting genuine authenticated requests in order to record the response. Note that the oauth token request itself will not be recorded.

    ```
    # .env.test.local OR .env.test
    COURT_DATA_ADAPTOR_API_TEST_MODE: false
    ```

  - run the tests

    this should write a cassette named after the specs filepath in the VCR root  - `spec/fxtures/vcr_cassettes`

  - turn test mode back on

    ```
    # .env.test.local OR .env.test
    COURT_DATA_ADAPTOR_API_TEST_MODE: true
    ```

    This will disable real OAuth2 access token requests. API endpoint requests should now be stubbed and therefore tests should pass with no locally running adaptor API or connectivity to hosted services. Try running tests again with no internet or local servers running.

## Notes

#### Initial app generation

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

