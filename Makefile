default: help

help: #: Show help topics
	@grep "#:" Makefile* | grep -v "@grep" | sort | sed "s/\([A-Za-z_ -]*\):.*#\(.*\)/$$(tput setaf 3)\1$$(tput sgr0)\2/g"

install: #: install all requirements
	@printf "\e[33mMAKE: brewing...\e[0m\n"
	@brew bundle
	@RUBYOPT=-W:no-deprecated
	@printf "\e[33mMAKE: install ruby $$(cat .ruby-version)...\e[0m\n"
	@rbenv install $$(cat .ruby-version)
	@printf "\e[33mMAKE: installing bundler...\e[0m\n"
	@gem install bundler -v $$(cat Gemfile.lock | tail -1 | tr -d " ")
	@printf "\e[33mMAKE: installing ruby dependencies...\e[0m\n"
	@bundle install
	@printf "\e[33mMAKE: installing node...\e[0m\n"
	@source $(HOME)/.nvm/nvm.sh ;\
		nvm install
	@printf "\e[33mMAKE: installing JS dependencies...\e[0m\n"
	@yarn install --frozen-lockfile
	@printf "\e[33mMAKE: db setup...\e[0m\n"
	@rails db:setup
	@printf "\e[33mMAKE: db migration...\e[0m\n"
	@rails db:migrate
	@printf "\e[33mMAKE: db seeding...\e[0m\n"
	@rails db:seed

run: #: run the application locally
	foreman start -f Procfile.dev

test: #: run test suite locally
	@printf "\e[33mMAKE: brakeman...\e[0m\n"
	@bundle exec brakeman --quiet --exit-on-warn 1> /dev/null
	@printf "\e[33mMAKE: rubocop...\e[0m\n"
	@bundle exec rubocop
	@printf "\e[33mMAKE: linters...\e[0m\n"
	@yarn run validate:js
	@yarn run validate:scss
	@printf "\e[33mMAKE: rspec...\e[0m\n"
	@RUBYOPT=-W:no-deprecated bundle exec rspec --format progress

open: #: open localhost:3000 in default browser
	@open http://localhost:3000

e2e: #: run cypress end to end testing
	@yarn install --frozen-lockfile
	@yarn run start:server && yarn run cypress:run
