# Common platform UI
An interace to the ???[laa-common-platform-connector](https://github.com/ministryofjustice/laa-common-platform-connector) or [laa-court-data-adaptor](https://github.com/ministryofjustice/laa-court-data-adaptor)??? for displaying information available from the HMCTS "common platform" API.


## System dependencies
- ruby 2.7.0+
- rails 6.0.2.1+
- node 13.5.0+
- yarn 1.21.1+

## Setup

```
# clone
git clone https://github.com/ministryofjustice/laa-common-platform-ui
cd laa-common-platform-ui

# install ruby if required
rvm install 2.7.0

# install node (using projects version)
nvm install

# install yarn. Must be yarn >= 1.0.0
brew install yarn
brew upgrade yarn

# install node modules using yarn
yarn install --frozen-lockfile

# setup database
rake db:setup
```

## Assets
The rails asset pipeline is disabled and all related config is commented out (it does not seem possible to remove sprockets entirely). We are using `webpacker` gem wrapper for `webpack`, and `yarn` for js dependency management.

To run app locally (development mode) you will therefore need to run both the `rails server` and the `webpack-dev-server` (for asset serving). see [Development](#Development)

## Development

To run the app locally you will need to run both a rails server and webpack dev server.

```
# in one terminal
rails s

# in another terminal
bin/webpack-dev-server
```

## Testing
TODO


## Notes

#### Initial app generation

This app was generated using the following initial `rails new` command, skipping all components we do not currently need.

```
# generate new rails app
rails new laa-common-platform-ui \
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

