# Greenhouse Integration

Greenhouse integration is import-only. That is, data is imported to Namely from
Greenhouse. This is done via a web hook, configured in the Greenhouse UI. See
the [Greenhouse web hook documentation][1] for more information on the web hook.

[1]: https://app.greenhouse.io/configure/web_hooks/documentation

## Creating a Connection

The Connect user creates a connection to Greenhouse via the connect UI. This is
a misnomer, as there is no connection made at all to Greenhouse. The Connect
user provides a name for the connection, which is seemingly of no actual use,
and is ultimately provided with a Webhook URL.

They then need to log in to Greenhouse and [create a new webhook][2] using the
URL provided by Connect. The Greenhouse UI will also ask for a `secret_key`,
which in Connect's case is actually the full path of the URL. Copy the path
(without the leading `/`) and use this as the secret key.

[2]: https://app.greenhouse.io/web_hooks

## Receiving Web Hook

When a candidate is hired in Greenhouse, Greenhouse will send their profile data
to the web hook URL. This is handled by the
`GreenhouseCandidateImportsController`, which creates a `CandidateImporter`,
injecting the `Greenhouse::CandidateImportAssistant` to handle Greenhouse
specifics.

## Mapping Attributes

The connect user can manage attribute mappings from Greenhouse to Namely. Only
the known standard fields from Greenhouse are provided for mapping, as
Greenhouse doesn't give us any way to get a list of possible custom fields for
mapping.

There is limited custom field support in the Greenhouse integration, but this is
handled by the `Greenhouse::Normalizer`.

## Normalizing Imported Data

For some fields, the data is received from Greenhouse in a format that can't be
directly mapped to the corresponding Namely field. This is where the
`Greenhouse::Normalizer` comes in. The normalizer will format the data in
certain fields so it is acceptable to Namely.

The Greenhouse normalizer is also responsible for the limited custom field
support available for this integration. The normalizer will map any custom
fields from Greenhouse that have identically labeled custom fields in Namely of
a compatible type. The `Greenhouse::CustomFields` object handles the mapping of
the custom fields.

## Future Improvements

* If Greenhouse can provide an API endpoint we could query to get custom fields,
  we could perhaps offer real, mappable custom field support.

* We should investigate moving the `CandidateImporter` logic into something that
  more closely resembles the workflow  employed by the NetSuite integration.
  That is, the `Greenhouse::Connection` class could support a `sync` method and
  kick things off from there.

* We should add activity feed tracking to the Greenhouse integration, perhaps
  even capturing the body of failed web hook calls, which would allow them to be
  retried.
