# README

Watchdoge is a watchdog for [API Entreprise](https://github.com/etalab/apientreprise), the monitoring done by Watchdoge is available on the [Dashboard](https://github.com/etalab/dashboard_apientreprise)

Watchdoge run on Ruby 2.4.2

## Configuration

### Database

The database user should exists, it uses PostgreSQL (cf. `config/database.yml`). Execute the following command line to create the default user:

`psql -f db/init.sql`

### Development environment

Run:

`rake dev:init`

It will init the development environement (defaults config files & database)

## Rake tasks

Run the main job in a rake task and get debug info (specify RAILS_ENV):

`rake watch:all`

Can run only one endpoint (specify RAILS_ENV):

`rake watch_v2:one cotisations_msa`

## Deployment

Run:

`mina deploy domain=<MY IP> to=<development|production>`

## Dependencies
Needs PostgreSQL installed,  certifcates (and IP whitelist) for API Entreprise and it's providers

## Services
Watchdoge use `whenever` to perform periodic pings. Mina updates cronotab on deployment.

## Tests
Due to Tools::PingWorker multithreading is can cause some tests to fails sometimes, re-run your tests to be sure
Run:

`rspec`
