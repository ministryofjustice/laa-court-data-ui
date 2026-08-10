# Installation and running

## System dependencies
- postgres
- ruby 3.1
- rails 6+
- nvm
- node 12.4.1+
- yarn 1.21.1+

## Installation
Clone the repository:
```
# clone
git clone https://github.com/ministryofjustice/laa-court-data-ui
cd laa-court-data-ui
```

Quick install on MacOSX:
```
# check ./Makefile for individual installation steps
make install
```

Or install manually (step-by-step):
```
# install fundamental dependencies(postgres, nvm, yarn)
brew bundle

# install ruby if required
rvm install $(cat .ruby-version)

# install gems
bundle install

# install node (using projects version `.nvmrc`)
nvm install

# install node modules using yarn
yarn install --frozen-lockfile

# build dependencies via webpack
yarn build

# setup database
rails db:setup
rails db:migrate
rails db:seed
```


## Creating a User

To create a user via the rails console:
```
> bundle exec rails c
> User.create!(
  first_name: 'Jane',
  last_name: 'Doe',
  username: 'jdoe',
  email: 'jane.doe@example.com',
  email_confirmation: 'jane.doe@justice.gov.uk',
  roles: ['caseworker', 'admin' ]
)
```

Important:
- Available roles: `caseworker`, `admin`, `data_analyst`.
- The user's email must have the `@justice.gov.uk` domain to be able to use Single Sign On (SSO).


## Running

To run the app locally you can use `rails server` or
```
foreman start -f Procfile.dev

# alternative, runs above command
make run
```

To communicate with a particular local or hosted adaptor for searching from your local development environment you should add an `.env.development.local` as below and restart the server.

```
# .env.development.local
COURT_DATA_ADAPTOR_API_URL: http://localhost:9292/api/internal/v1
COURT_DATA_ADAPTOR_API_UID: uid-for-adaptor-api-above
COURT_DATA_ADAPTOR_API_SECRET: secret-for-adaptor-api-above
```

The uid and secret can be generated as described by [laa-court-data-adptor#api-authentication](https://github.com/ministryofjustice/laa-court-data-adaptor#api-authentication)

Alternatively, if you want to communicate with the local version of the adaptor service (which in turn communicates with
the hosted version of `hmcts-common-platform-mock-api`), you can set up the `.env.development` file with the following
command:

```
make setup_env
```

You can then run the app with the following command:

```
foreman start -f Procfile.local.dev
```
