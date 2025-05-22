# View court data

A service to enable Legal Aid Agency (LAA) caseworkers to view and "link" Court data related to a claim for remuneration. This is primarily an interface to the [laa-court-data-adaptor](https://github.com/ministryofjustice/laa-court-data-adaptor) API, which in turn is a conduit providing a layer of abstraction around the HMCTS "common platform" API.

[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-court-data-ui.svg?style=svg)](https://circleci.com/gh/ministryofjustice/laa-court-data-ui)
[![Code Climate](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui)
[![Test Coverage](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/laa-court-data-ui/coverage)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Quick start (on macosx)
```
make install

make run

make open
```

## Pre-commit hooks
We have gitleaks set up on this repo. To make it harder to accidentally leak a secret, have it run as a pre-commit hook:
```
pip install pre-commit
pre-commit install
```

## Documentation

* [Installation and running](docs/installation.md)
* [Development](docs/development.md)
* [Testing](docs/testing.md)
* [Monitoring](docs/monitoring.md)
