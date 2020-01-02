# Common platform UI
An interace to the ???[laa-common-platform-connector](https://github.com/ministryofjustice/laa-common-platform-connector) or [laa-court-data-adaptor](https://github.com/ministryofjustice/laa-court-data-adaptor)??? for displaying information available from the HMCTS "common platform" API.


## System dependencies
- postgres
- ruby 2.7.0+
- rails 6.0.2.1+
- nvm
- node 13.5.0+
- yarn 1.21.1+

## Setup

Clone:
```
# clone
git clone https://github.com/ministryofjustice/laa-common-platform-ui
cd laa-common-platform-ui
```

Install OS dependencies (macosx):
```
brew bundle
```

Install app dependencies:
```
# install ruby if required
rvm install 2.7.0

# install gems
bundle install

# setup database
rails db:setup

# install node (using projects version)
nvm install

# install node modules using yarn
yarn install --frozen-lockfile
```

## Assets
The rails asset pipeline is disabled and all related config is commented out (it does not seem possible to remove sprockets entirely). We are using `webpacker` gem wrapper for `webpack`, and `yarn` for js dependency management.

To run app locally (development mode) you will therefore need to run both the `rails server` and the `webpack-dev-server` (for asset serving). see [Development](#Development)

## Development

To run the app locally you will need to run both a rails server and webpack dev server.

You can do this in two different terminals
```
# in one terminal
rails s

# in another terminal
bin/webpack-dev-server
```

or using a single terminal and foreman
```
foreman start
```

## Testing

#### Ruby 2.7 deprecation warnings
There are a lot of warnings related to ruby 2.7 and rails 6.0.2.1. These are largely related to use of keyword arguments, such as below, and should be fixed
in rails patches in the future:
```
..action_dispatch/middleware/stack.rb:37: warning: Using the last argument as keyword parameters is deprecated; maybe ** should be added to the call
```

To suppress for now you can prefix any call that raises such warnings with `RUBYOPT=-W:no-deprecated`:
```
RUBYOPT=-W:no-deprecated rspec
RUBYOPT=-W:no-deprecated rails server
```

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

