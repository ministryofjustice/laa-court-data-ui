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

## Linking court data to MAAT

One of the purpose of this service is to "link" HMCTS court records to a legal-aid
record in MAAT (via **MAAT ID**).
There are **two distinct things that can be linked**:

### 1. Prosecution case

A *prosecution case* is the original criminal proceedings brought against one or more **defendants** (the "first instance" case), identified by its case **URN**.
A caseworker links an individual **defendant** on that case to a MAAT ID.

**Controllers/Actions:**

| Step | Controller#action | Route | CDA resource |
| --- | --- | --- | --- |
| Show link form | `LaaReferencesController#new` | `GET /laa_references/new` | – |
| Create link | `LaaReferencesController#create` | `POST /laa_references` | `Cda::ProsecutionCaseLaaReference.create!` |
| Show unlink form | `DefendantsController#edit` | `GET /defendants/:id/edit` | – |
| Unlink | `DefendantsController#update` | `PATCH /defendants/:id` | `Cda::ProsecutionCaseLaaReference.update!` |

### 2. Court application

A *court application* is a follow-on matter related to a prosecution, rather than the original case.

It comes in three categories — **Appeal**, **Breach** and **POCA** (Proceeds Of Crime Act) — and its person is the **subject** (an
*appellant* for appeals, otherwise a *respondent*).

A caseworker links that subject to a MAAT ID. The link/unlink mechanics are identical across all three categories.

A refactor is in progress to give **each category its own dedicated link page** via the new linking journey (`SubjectsController#show_link`). Breach is done (`show_link_breach`); appeal and POCA will follow.

**Controllers/Actions:**

| Step | Controller#action | Route | CDA resource |
| --- | --- | --- | --- |
| Detail / link form | `SubjectsController#show` | `GET /court_applications/:id/subject` | – |
| New link journey | `SubjectsController#show_link` | `GET /court_applications/:id/subject/link` | – |
| Create link | `SubjectsController#link` | `POST /court_applications/:id/subject/link` | `Cda::CourtApplicationLaaReference.create!` |
| Unlink | `SubjectsController#unlink` | `POST /court_applications/:id/subject/unlink` | `Cda::CourtApplicationLaaReference.update!` |

Both flows share the same form objects (`LinkAttempt` / `UnlinkAttempt`) and the `maat_ref_required` validation convention.
They differ in the CDA resource they call and the views they render.

## Documentation

* [Installation and running](docs/installation.md)
* [Development](docs/development.md)
* [Testing](docs/testing.md)
* [Monitoring](docs/monitoring.md)
