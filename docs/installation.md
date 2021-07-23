# Installation and running

## Application dependencies for running locally
- postgres
- ruby 2.7+
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

# setup database
rails db:setup
rails db:migrate
rails db:seed
```


## Running
### Running the application in Docker
VCD has the ability to run through docker. To do this run the following command:

```
docker-compose up vcd --build -d
```
The following command will run a postgres database in docker and VCD in docker and allow the 2 to talk. It will also seed the database with test data to allow for testing and using the software. Once complete you can use the following command:

```
docker-compose down vcd
```
This will stop and clean up the containers you had created so that you have a fresh run each time you start up.

### Running the application locally

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

