# Testing

For testing we use [rspec](https://relishapp.com/rspec/). Linters and static analysers are also run - [rubocop](https://github.com/rubocop-hq/rubocop), Stylelint, jlint-js [brakeman](https://brakemanscanner.org/docs/introduction/)).

## Running test suite

Simplest way to run entire test suite is to use the [Makefile](#makefile)
```
make test
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

# run the end to end tests
make e2e
```

## VCR and Webmock

Since the primary function of the app is to search data via an API, webmock and VCR play a significant role in testing. For this application's purposes the test suite should pass without any connectivity. If not writing stubs manually then VCR cassettes must be generated against actual running adaptor APIs.

The API requires OAuth2 authentication using app-specific `client_credentials`. see [Local stack setup](development.md) for details on obtaining and configuring `client_credentials`.

OAuth2 access token requests are configured to be be ignored by VCR to avoid problems with loading of the client. Instead the client is configured to not attempt to retrieve an access token from the adaptor when in `test_mode`. To record new cassettes therefore requires:

- Creating new cassettes (Quickstart)
    * switch `test_mode` off - see below
    * *optionally, empty or delete existing cassette if rerecording*
    * run the test (with `:vcr` tag) to (re)record the cassette
    * switch `test_mode` on

- Creating new cassettes (step-by-step)

  - check you can successfully query the adaptor

    You should be able to to retrieve the results you expect against a locally running version of the adaptor, or a hosted one. see the instructions on [local stack setup](docs/development.md)

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
