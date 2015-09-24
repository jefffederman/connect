# Namely Connect

[![Code Climate](https://codeclimate.com/github/namely/connect/badges/gpa.svg)](https://codeclimate.com/github/namely/connect)
[![Circle CI](https://circleci.com/gh/namely/connect.svg?style=svg&circle-token=07c371714354bf58f4d2af8e0d92d793b5998880)](https://circleci.com/gh/namely/connect)

Enables integration between Namely and external HRIS apps.

## Getting Set Up

This project assumes Docker for local development. You may be able to use it in
a more traditional local setup, but it may require some tweaking of environment
variables or configuration.

### 1. Docker Installation

You will need a Docker environment to run this project locally. If you are on
Linux, install `docker` and `docker-compose` with your package manager.

If you are on OS X or Windows, you will need to install additional tools.  The
simplest way to install these is the with [Docker Toolbox]. Once the toolbox is
installed, we'll be interacting with it [from the shell]. You'll likely want to
add `eval "$(docker-machine env default)"` to your shell initialization scripts
to be sure your `docker-machine` environment is always configured.

A complete docker tutorial is out of scope here, but please be sure to read the
documentation for your platform.

[Docker Toolbox]: https://www.docker.com/toolbox
[from the shell]: https://docs.docker.com/installation/mac/#from-your-shell

### 2. Building Your Docker containers

This application will use three docker containers; one each for the database,
the web process, and the worker process. We use `docker-compose` to control them
all in concert.

```sh
cp .sample.env .env
docker-compose build
docker-compose run web rake db:setup
```

### 3. Accessing the Web Application

We can start all of the containers with the following command:

```sh
docker-compose up
```

This will make the web app available. If you are using Linux, it will be at
http://localhost:3000.

If you are using OS X or Windows, you will need to know
the IP of the virtual machine that docker is running in. You can get this with
`docker-machine ip default`. This seems to be stable between reboots, so you may
want to set up an entry in your hosts file for `docker.dev` or similar. On my
machine, the app is available at http://192.168.99.100:3000.

### 4. Running the Tests

The tests are run via docker as well.

```sh
docker-compose run web rake
```

To make this process as seamless as possible, you can use local binstubs to pass
your usual development environment commands (`rake`, `rspec`, `rails`) through
docker-compose for you.

This project includes these binstubs in the `local_bin` directory, which can be
added to your `PATH`.

## Required Configuration

The app interfaces with the Namely API and external APIs for the supported
integrations. At a minimum you will need an account on a Namely sandbox. Request
access to a sandbox from [Attila].

[Attila]: mailto:attila@namely.com

### Namely Client Configuration

Once you have access to your Namely sandbox, you will need to register your
development environment instance with that sandbox.

1. Log in to your sandbox
2. In the drop-down menu next to your avatar, select "API".
3. Click "New API Client"
4. Enter your Namely sandbox URL in Website (e.g.
   `https://thoughtbot-sandbox.namely.com`).
4. Enter your local development oauth callback URL in "Redirect URI" (e.g.
   `http://docker.dev:3000/session/oauth_callback`).
5. Click submit and note the "Client Identifier" and "Client Secret" provided.
6. Edit your `.env` file and input the tokens from step 5 as your
   `NAMELY_CLEINT_ID` and `NAMELY_CLIENT_SECRET`.

### Cloud Elements Client Configuration

[Cloud Elements] is used to wrap NetSuite's SOAP API in a JSON REST API that is
much easier to consume. You will need access to the Cloud Elements UI, which you
can request from [Attila].

Once you have access, you can configure your Cloud Elements client.

1. Log in to [Cloud Elements]
2. On the right side of the header, click "secrets".
3. Copy and paste the `Org Secret` and `User Secret` to the `.env` file as
   `CLOUD_ELEMENTS_ORGANIZATION_SECRET` and `CLOUD_ELEMENTS_USER_SECRET`,
   respectively.

[Cloud Elements]: https://console.cloud-elements.com/elements/jsp/login.jsp
[Attila]: mailto:attila@namely.com

## External Service Accounts

There are shared accounts for the following services, which can be used when
connecting to these services through the connect app or to log in to the
external services themselves.

* [NetSuite]
* [Greenhouse]
* [Jobvite]
* [iCIMS]

The credentials for these shared accounts can be found in the comments of this
[Trello] card.

[NetSuite]:https://system.netsuite.com/pages/customerlogin.jsp
[Greenhouse]:https://app.greenhouse.io/users/sign_in
[Jobvite]:https://app.jobvite.com/Login/jvLogin.aspx?role=em
[iCIMS]: https://preview5test.icims.com/icims2/servlet/icims2?module=Root&action=login&hashed=993052824
[Trello]: https://trello.com/c/wNianPJX/116-account-credentials

## Integration Documentation

Overview documentation on the integrations may be located in the `/doc`
directory of this repository.

## Regenerating Test Fixtures

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

## Rake Tasks

To import newly hired Jobvite candidates for all users, run:

```sh
docker-compose run web rake jobvite:import
```

To export Namely profile data to NetSuite, run:

```sh
docker-compose run web rake net_suite:export
```

These tasks can be invoked by a cron job or otherwise scheduled to regularly
import or export data.
