# Jobvite Integration

Jobvite integration is import-only. That is, data is imported to Namely from
Jobvite. The Jobvite API documentation is not available online. A copy of the
documentation we were provided is located in this repository's `doc` directory.

## Creating and Working with a Connection

The Connect user will be asked for their API Key and secret when setting up the
`Jobvite::Connection` from Connect. This data is available in the Jobvite web
interface.  For development connection details see the `README`.

The `Jobvite::Client` encapsulates the communication with the Jobvite API and
exposes only the `recent_hires` method, which will get all hired candidates from
Jobvite.
