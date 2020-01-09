default: help

help: #: Show help topics
	@grep "#:" Makefile* | grep -v "@grep" | sort | sed "s/\([A-Za-z_ -]*\):.*#\(.*\)/$$(tput setaf 3)\1$$(tput sgr0)\2/g"

install: #: install all requirements
	@brew bundle
	@rvm install $$(cat .ruby-version)
	@bundle install
	@rails db:setup
	@rails db:migrate
	@source $(HOME)/.nvm/nvm.sh ;\
		nvm install
	@yarn install --frozen-lockfile

run: #: run the application locally
	foreman start -f Procfile.dev

test: #: run test suite locally
	bundle exec brakeman --quiet --exit-on-warn
	bundle exec rubocop
	bundle exec rspec -fd
