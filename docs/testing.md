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

## Pact tests

This application uses [Pact](https://docs.pact.io/) to specify the API contract between this application and the
[laa-court-data-adaptor](https://github.com/ministryofjustice/laa-court-data-adaptor).

Pact tests are stored in the `spec/pacts` directory and are not run as part of the standard test suite. To run the
Pact tests, you can use the following command:

```
bundle exec rspec -t pact
```

The tests are run against a mock server that simulates the responses  from the laa-court-data-adaptor API.

The responses from the mock server are setup like so:

```ruby
interaction = new_interaction
  .given('a valid request') # this is the provider state, which will be used by the laa-court-data-adaptor to setup the correct data for the response
  .upon_receiving('a request for court data')
  .with( # this is the request that will be sent to the mock server
    method: :get,
    path: '/court-data',
    headers: {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  ).will_respond_with( # this is the response that the mock server will return
    status: 200,
    headers: {
      'Content-Type' => 'application/json'
    },
    body: {
      court_data: [
        {
          id: 1,
          name: 'Court 1'
        },
        {
          id: 2,
          name: 'Court 2'
        }
      ]
    }
  )
```

Within the Pact tests, we can then execute the interaction against the mock server and verify that the response is as
expected. For example, if we have a class that makes a request to the laa-court-data-adaptor API like so:

```ruby
class CourtDataClient
  self.site = ENV.fetch("COURT_DATA_ADAPTOR_API_URL")

  def get_court_data
    response = Faraday.get("#{self.site}/court-data")
    JSON.parse(response.body)
  end
end
```

We can then write a Pact test that verifies that the `get_court_data` method makes the correct request to the mock
server and returns the expected response:

```ruby
interaction.execute do |mock_server|
  # Do something that ensures the code under test makes a request to the `mock_server`
  CourtDataClient.site = mock_server.base_url
  result = CourtDataClient.new.get_court_data

  expect(result["court_data"]).to eq([{ "id" => 1, "name" => "Court 1" }, { "id" => 2, "name" => "Court 2" }])
end
```

When Pact tests run, they generate a Pact file that describes the interactions between this application and the
laa-court-data-adaptor API as JSON.

On every push to a branch, the Pact tests are run, and the Pact file is generated and
uploaded to the [Pact Broker](https://laa-data-pact-broker.apps.live.cloud-platform.service.justice.gov.uk/) via the [Pact GitHub Actions workflow](https://github.com/ministryofjustice/laa-court-data-ui/actions/workflows/pact.yml).

This allows laa-court-data-adaptor to pull down the Pact file and verify that it is compatible with the API contract
defined by this application. If there are any changes to the API contract, the Pact tests in laa-court-data-adaptor
will fail.

For more information, see the [Pact documentation](https://docs.pact.io/).
