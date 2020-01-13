default: help

help: #: Show help topics
	@grep "#:" Makefile* | grep -v "@grep" | sort | sed "s/\([A-Za-z_ -]*\):.*#\(.*\)/$$(tput setaf 3)\1$$(tput sgr0)\2/g"

install: #: install all requirements
	@printf "\e[33mMAKE: brewing...\e[0m\n"
	@brew bundle
	@RUBYOPT=-W:no-deprecated
	@printf "\e[33mMAKE: install ruby $$(cat .ruby-version)...\e[0m\n"
	@rvm install $$(cat .ruby-version)
	@printf "\e[33mMAKE: installing ruby dependencies...\e[0m\n"
	@bundle install
	@printf "\e[33mMAKE: db setup...\e[0m\n"
	@rails db:setup
	@printf "\e[33mMAKE: db migration...\e[0m\n"
	@rails db:migrate
	@printf "\e[33mMAKE: db seeding...\e[0m\n"
	@rails db:seed
	@printf "\e[33mMAKE: installing node...\e[0m\n"
	@source $(HOME)/.nvm/nvm.sh ;\
		nvm install
	@printf "\e[33mMAKE: installing JS dependencies...\e[0m\n"
	@yarn install --frozen-lockfile

run: #: run the application locally
	foreman start -f Procfile.dev

test: #: run test suite locally
	@bundle exec brakeman --quiet --exit-on-warn
	@bundle exec rubocop
	@RUBYOPT=-W:no-deprecatedbundle exec rspec -fd
