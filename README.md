# Namely Connect

[![Code Climate](https://codeclimate.com/github/namely/connect/badges/gpa.svg)](https://codeclimate.com/github/namely/connect)
[![Circle CI](https://circleci.com/gh/namely/connect.svg?style=svg&circle-token=07c371714354bf58f4d2af8e0d92d793b5998880)](https://circleci.com/gh/namely/connect)

Simple web app for connecting external apps with Namely.

Planned integrations:

* Jobvite (create new Namely Profiles based on candidate data)

## Getting set up

### 0. Install VirtualBox

Download from the [VirtualBox
downloads](https://www.virtualbox.org/wiki/Downloads) page.

### 1. Install Docker & boot2docker  & Docker Machine & Docker Compose

osx:
```sh
brew install docker-compose
```

### 2. Initialize and boot Docker container with `boot2docker`

osx:
```sh
boot2docker init
boot2docker up
```

### 3. Build docker image

```sh
docker-compose build
```

### 4. Setup Environment Variables

```sh
cp .sample.env .env
```

### 5. Run all services

```sh
docker-compose up
```

### 6. Set-up the database

```sh
docker-compose run web rake db:setup
```

### 7. Run the tests:

```sh
docker-compose run web rake
```

### 8. Required accounts

Make sure you have accounts or access for the following:

* Heroku Staging
* Namely (likely on a sandbox)

### 9. Project-specific accounts

Depending on what manner of integration you will be working on, you may also
need one or more of the following:

* NetSuite if you're adding a new NetSuite integration or working on an existing
  NetSuite integration
* Cloud Elements if you're working with a NetSuite integration or another
  integration that works with Cloud Elements
* Jobvite

### Connecting API client

* Log into the Sandbox
* Go to "API" from the profile dropdown (looks like a person's head next to the
  search bar)
* Click "New API Client"
* Fill in the form
  * Name: Connect
  * Website: `<name>-sandbox.namely.com`
  * Redirect URI: `http://localhost:<port>/session/oauth_callback`
* Make a note of the Client Identifier and Client Secret and add those to the
  `.env` file as `NAMELY_CLIENT_ID` and `NAMELY_CLIENT_SECRET`.

## Test fixtures

When changing feature specs that make API calls, you will need to rebuild one or
more API fixtures (in `spec/fixtures`). When running these specs,
you will have to set the following environment variables in your `.env` file:

* `TEST_JOBVITE_KEY` and `TEST_JOBVITE_SECRET`: A valid Jobvite API key and
  secret.
* `TEST_NAMELY_SUBDOMAIN`: The subdomain of a Namely sandbox account, e.g. if
  the account is at `foobar.namely.com`, you would set this to `foobar`.
* `TEST_NAMELY_ACCESS_TOKEN`: A valid access token for the Namely sandbox
  account specified by `TEST_NAMELY_SUBDOMAIN`.
* `TEST_NAMELY_AUTH_CODE`: An OAuth auth code for the Namely sandbox account
  specified by `TEST_NAMELY_SUBDOMAIN`.

## Importing data from Jobvite to Namely

To import newly hired Jobvite candidates for all users, run:

```sh
docker-compose run web rake jobvite:import
```

This task can be invoked by a cron job or otherwise scheduled to regularly
import newly hired candidates.

