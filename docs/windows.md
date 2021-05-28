# Installation of dependencies and running on a Windows 10 machine

## System dependencies
- Windows Subsystem for Linux 2
- Postgres
- Ruby 2.7+
- Rails 6+
- NVM
- Node 12.4.1+
- Yarn 1.21.1+
- VS Code (or other suitable IDE)

## Install WSL2
Follow guidance on [microsoft.com](https://docs.microsoft.com/en-us/windows/wsl/install-win10#finish-with-verifying-what-versions-of-wsl-your-distro-are-using)

## Inside the Ubuntu terminal

### Install Postgres
```
apt install postgresql
```
### Install NVM
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
```
As per the [NVM installation instructions](https://github.com/nvm-sh/nvm#install--update-script)

### Postgres

```
sudo service postgresql start
sudo -u postgres psql
sudo -u postgres createuser [user_name]
sudo -u postgres createdb [db_name]
psql
ALTER USER [user_name] WITH SUPERUSER;
```

## Makefile and Brewfile
These steps replicate the Makefile (including Brewfile) installation, which are otherwise dependent on MacOS.  

### Install NVM

```
nvm install --lts
sudo apt install nodejs (14.17)
sudo apt install npm
```
[Stack overflow question](https://stackoverflow.com/questions/8935341/npm-wont-run-after-upgrade/8935401#8935401)

### Install Yarn 1.22.10
```
npm install yarn -g
```

### install Ruby
[RVM package for Ubuntu](https://github.com/rvm/ubuntu_rvm)
```
rvm install "ruby-2.7.2"
```

```
sudo apt install libpq-dev
bundle install
yarn install
```

### Rails
```
rails webpacker:compile
```
(If doesn’t work then: `RAILS_ENV=test rake webpacker:compile`)


## IDE

[Download **Visual Studio Code**](https://code.visualstudio.com/)

[Download VS Code ‘Remote WSL’ extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

## Required files

### `.bashrc`

In the Ubuntu terminal:

```
# Go to home directory
cd ~

# Create .bashrc file if not already existing
touch .bashrc

# Edit it in VS Code
code .bashrc
```

In VS code, add these lines in.  
```
# The first line opens VS Code in the project directory - this is optional
code ./laa-court-data-ui

# This starts Postgres each time and is required once per session
# You may want to do this manually depending on your ways of working
sudo service postgresql start

# NVM stuff
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

In the Ubuntu terminal:

### `.env.development.local`
To communicate with a particular local or hosted adaptor for searching from your local development 
environment you should add an `.env.development.local` as below and restart the server.

In the Ubuntu terminal

```
cd laa-court-data-ui # enters the project directory
touch .env.development.local # creates the local env file if not already existing
code .env.development.local # opens VS Code to edit the file
```

In VS Code add the following

```
# Dev CDA
# COURT_DATA_ADAPTOR_API_URL: https://laa-court-data-adaptor-dev.apps.live-1.cloud-platform.service.justice.gov.uk/api/internal/v1
# COURT_DATA_ADAPTOR_API_UID: iixPLiR_iv4i8QMPOdBev3JOL4CUKi_BesXutznUa40
# COURT_DATA_ADAPTOR_API_SECRET: 4fbnXvPMV-dHMUtUX8GATSeDBUioETr2NL2lmp-be6o
DISPLAY_RAW_RESPONSES: true

# UAT DEVELOPMENT CDA
COURT_DATA_ADAPTOR_API_URL: https://laa-court-data-adaptor-uat.apps.live-1.cloud-platform.service.justice.gov.uk/api/internal/v1
COURT_DATA_ADAPTOR_API_UID: 3xEBnKBITTkFtJWIb_4COHf22yZxzycq6OrrRS7JZJQ
COURT_DATA_ADAPTOR_API_SECRET: 54Q2oRyTzFvteQKVI7cEkEUBOvH1vNrDly4wqMsOZFk
```

## Day-to-day running

### Starting WSL

- Start Ubuntu
- If you have edited the `.bashrc` file as above, VS Code will start.  
- If not, be sure that the following is run:
  - `sudo service postgresql start`

You will be prompted for your password, you can enter it in the Ubuntu terminal or in the VS Code terminal.  You only need to enter it once.  

### Starting the server

- In the Ubuntu or VS Code terminal (usually whichever one you entered your password for), type `rails s`
- In a browser window, go to `http://localhost:3000/`

### Searching using Agent Ransack (etc)

- Agent Ransack can search the project by going to
```
\\wsl$\Ubuntu\home\[user_name]\laa-court-data-ui\
```