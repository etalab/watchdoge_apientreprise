# README

Watchdoge is a watchdog for [API Entreprise](https://github.com/etalab/apientreprise), the monitoring done by Watchdoge is available on the [Dashboard](https://github.com/etalab/dashboard_apientreprise)

Watchdoge run on Ruby 2.4.0

## Configuration

### Database

The database user should exists, it uses PostgreSQL (cf. `config/database.yml`). Execute the following command line to create the default user:

`psql -f db/init.sql`

### Development environment

Run:

`rake dev:init`

It will init the development environement (defaults config files & database)

## Rake tasks

Run the main job in a rake task and get debug info:

`rake watch:apie_v2`

Store *HTTP Responses* for all endpoints in json files. They will be used to confirm HTTP responses validity in production:

`rake watch:store_responses`

## Deployment

Run:

`mina deploy domain=<MY IP> to=<development|staging|production>`

## Dependencies
Needs PostgreSQL installed,  certifcates (and IP whitelist) for API Entreprise and it's providers

## Jobs
Watchdoge use `crono` to perform periodic pings Mina start the deamon automatically.

To do it manually :

`bundle exec crono start -N watchdoge-crono -e development`

## Tests
Run:

`rspec`
