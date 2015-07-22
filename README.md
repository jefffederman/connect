# Namely Connect

[![Code Climate](https://codeclimate.com/github/namely/connect/badges/gpa.svg)](https://codeclimate.com/github/namely/connect)
[![Circle CI](https://circleci.com/gh/namely/connect.svg?style=svg&circle-token=07c371714354bf58f4d2af8e0d92d793b5998880)](https://circleci.com/gh/namely/connect)

Simple web app for connecting external apps with Namely.

This app imports and exports data between Namely and other third-party data
providers.

### Import

#### Jobvite

Get credentials for Jobvite from Attila Maczak or from Paul. Once you get a
Jobvite key and secret, add to your `.env`:

```sh
TEST_JOBVITE_KEY=...
TEST_JOBVITE_SECRET=...
```

The documentation for the Jobvite API is only available from the signed-in
Jobvite Web site.

The Jobvite import happens via the `SyncsController` with `integration_id` set
to `jobvite`.

#### iCIMS

Get credentials for iCIMS from Attila Maczak or from Paul. When creating a
connection to iCIMS using the Namely Connect UI, use your credentials.

iCIMS exposes [a documented REST API][icims].

[icims]: https://developer.icims.com/REST-API/Integration-Events

Follow `IcimsCandidateImportsController` for an introduction.

#### Custom

To create a new import, for an API named "Foo":

1. Add a test to `spec/features/user_imports_foo_spec.rb`. Here is a sample:

```ruby
    visit dashboard_path(as: user)
    within(".foo-account") do
      click_button t("dashboards.show.import_now")
    end

    expect(page).to have_content t("syncs.create.slogan", integration: "Foo")

    open_email user.email
    expect(current_email).to have_text(
      t(
        "sync_mailer.sync_notification.succeeded",
        employees: t("sync_mailer.sync_notification.employees", count: 2),
        integration: "Foo"
      )
    )
```

2. Add a `has_one` connection for `User` to the desired connection. It is named
   `foo_connection`, with a class name of `Foo::Connection`.
3. Define the `Foo::Connection` class. It must respond to `#sync`. `#sync`
   takes no arguments and produces an Enumerable of Results.

   A Result adheres to the following interface:

    name :: -> String
    success? :: -> Boolean

4. The `Foo::Connection#sync` method may make use of the `Importer` class. This
   involves building `Foo::AttributeMapper` and `Foo::Client` classes.
   
   The `Foo::AttributeMapper` instance is a Proc-like object that responds to
   `#call`. `Foo::AttributeMapper#call` takes an object representing the Foo
   candidate, and produces a Hash that maps from the Namely field to Foo's
   value. As a trivial example:

    def call(candidate)
      { 'first_name' => candidate['fName'] }
    end

   The `Foo::Client` class must respond to `::Error` and `#recent_hires`. The
   `#recent_hires` method produces an Array for Foo candidates, as passed to
   `Foo::AttributeMapper#call`.

### Export

#### Netsuite

The official Netsuite API uses SOAP. To make life easier, we connect using
Cloud Elements. You will need a Cloud Elements account; Attila or Paul can
help. Once you have your credentials, update your `.env`:

```sh
CLOUD_ELEMENTS_ORGANIZATION_SECRET=...
CLOUD_ELEMENTS_USER_SECRET=...
```

Documentation can be found in the Cloud Elements console. Each documentation is
specific to the integration, so on the left you must navigate through the
integrations, then select the "Documentation" tab for the relevant integration.

The Netsuite export happens via the `SyncsController` with `integration_id` set
to `netsuite`.

#### Greenhouse

Get credentials for Greenhouse from Attila or Paul. When creating a connection
to Greenhouse using the Namely Connect UI, use your credentials.

The documentation for the Greenhouse API is only available from the signed-in
Greenhouse Web site.

Start reading at `GreenhouseCandidateImportsController`.

#### Custom

### Namely

All of this depends on you having access to Namely. Be sure to follow the
"Connecting API client" section below.

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

### 4. Run all services

```sh
docker-compose up
```

### 5. Set-up the database

```sh
docker-compose run web rake db:setup
```

### 6. Run the tests:

```sh
docker-compose run web rake
```

### 7. Required accounts

Make sure you have accounts or access for the following:

* Heroku Staging
* Namely (likely on a sandbox)

### 8. Project-specific accounts

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
  `web/environment` section of `docker-compose.yml` as `NAMELY_CLIENT_ID` and
  `NAMELY_CLIENT_SECRET`

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

