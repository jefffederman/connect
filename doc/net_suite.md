# NetSuite Integration

NetSuite integration is export-only. That is, data is exported from Namely to
NetSuite. Integrations with NetSuite is performed via [Cloud Elements], which
allows Connect to interface with Cloud Element's RESTful API while Cloud
Elements worries about communicating with NetSuite's SOAP and single sign on
APIs. Details on accessing and configuring Cloud Elements are in the `README`.

In many ways, the architecture of the NetSuite integration code represents the
model upon which any future integrations should be built: connection, attribute
mappings, normalizing data, background syncs, and finally the activity feed. The
other existing integrations have been updated to incorporate some of this
architecture where it made sense, but the focus was on delivering NetSuite as
best and as quickly as we could.

[Cloud Elements]: https://console.cloud-elements.com/elements/jsp/login.jsp

## Creating and Working with A Connection

When a user creates a `NetSuite::Connection`, they are actually creating a
Cloud Elements instance which speaks to their NetSuite application. You can see
the Cloud Elements API documentation for your instance by logging into Cloud
Elements and finding your instance in the list. Instances are named for the
environment and time that they are created.

Communication to the Cloud Elements API is handled in the `NetSuite::Client`
class. This class has, most notably, `create_employee` and `update_employee`
methods. These will use the `NetSuite::Client::Request` object to actually send
the request. Successful requests will be returned as `NetSuite::Client::Result`
objects.

## Mapping Attributes

The NetSuite connection allows users to map fields between Namely and NetSuite.
There is a list of attributes that are used as default field mappings. You can
see those in `NetSuite::Client#map_standard_fields`.

The `AttributeMapper` has methods that map fields for both importing and
exporting. The mapper itself has many `FieldMapping` records which store the
source and destination field names.

Custom mappings are likely most useful in the case of custom fields on either
the NetSuite or Namely side. Unfortunately, there is no NetSuite API for us to
use to get a list of possible NetSuite custom fields. To overcome this, we
resort to pulling in the first five employee records from NetSuite and scraping
their profiles for the list of fields. See `NetSuite::EmployeeFieldLoader`.

There is an outstanding [Cloud Elements bug] that prevents this custom field
scraping from working as originally intended. Cloud Elements will return fields
in an employee record that cannot actually be set without error. These fields
are marked as "hidden" in the NetSuite UI and as such are not settable via the
API either. See the bug for more detail.

[Cloud Elements bug]: http://support.cloud-elements.com/hc/requests/1069

We have added a feature flag, `NET_SUITE_CUSTOM_FIELDS_ENABLED` that control
weather the integration will support NetSuite custom fields. This is currently
set to `false` in staging and production, but `true` in development to allow for
testing the resolution of the bug.

## Normalizing Exported Data

Some data cannot be mapped directly between a Namely field and a corresponding
NetSuite field without being transformed first. This is the job of the
`NetSuite::Normalizer`.

For an example, let's look at the `releaseDate` field in NetSuite. By default,
we map Namely's `departure_date` field here, which is returned from Namely as a
string value with a type of `date`. The `Fields::Collection` object is
responsible for wrapping this value in a `Fields::DateValue` object based on
that specified `date` type. The `NetSuite::Normalizer` knows that any value sent
to `releaseDate` in NetSuite must be specified as milliseconds since epoch. To
do the conversion it calls `Fields::DateValue#to_date` to get hold of a proper
DateTime object and then converts the value to milliseconds since epoch, as
required by NetSuite.

A similar process is followed for other fields, such as address,  where types or
format may not align between the two systems.

The `NetSuite::Export` object calls the `NetSuite::Normalizer` just prior to
sending the data for export.

## The Sync Process

Connect users can sync Namely profile data to NetSuite on demand with the
"Export Now" button on their dashboard. This will enqueue the `SyncJob`
background job with a reference to their `NetSuite::Connection`.

The `SyncJob` is generic and can be used by any connection that supports a
`sync` method. In NetSuite's case, the job will execute
`NetSuite::Connection#sync`, which will sync each Namely profile to NetSuite.

The sync is executed in the context of a `Notifier` which is responsible for
catching errors and notifying users of both errors and successes.

There is also the `net_suite:export` rake task, which uses the `BulkSync` class
to enqueue a single `SyncJob` for each configured NetSuite integration. This is
intended to be run nightly in production (and hourly on staging).

## The Activity Feed

The `Notifier` class mentioned above will both email users of successes and
failures and record those same successes and failures as `SyncSummary` events,
with profile-level details stored as associated `ProfileEvent`s. This data is
used to populate the user's Activity Feed.

In the case of failure, the activity feed will show a list of profiles that
failed to sync along with the error message returned. Once the connect user
believes they have fixed any underlying issues, they can retry just the failed
profiles from the activity feed. This will use the `RetryJob` which operates
nearly identically to the `SyncJob` except that it calls
`NetSuite::Connection.retry` and retries only the profiles that have
corresponding failed profile events.

Activity feeds are currently only exposed on the NetSuite integration, but this
is not a technical limitation, but rather a matter of priority. Any integration
currently using the `SyncJob` will have activity data recorded.

## Future Enhancements

* Limit the API calls made to Cloud Elements and speed up overall export times
  by skipping profiles that have not changed since the last sync. The Namely api
  provides no last updated timestamp on profiles, so we'd have to use a
  different approach. Perhaps we could record MD5s of the last successful
  profile export for each profile and skip the API call if what we're about to
  send matches. This will likely be increasingly important as larger
  teams use this integration.

* Back-port the general architecture of the NetSuite solution to the other
  integrations so the patterns are more prevalent. This has happened somewhat,
  but is not complete.
