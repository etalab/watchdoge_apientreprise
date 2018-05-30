# README [![Build Status](https://travis-ci.org/etalab/watchdoge_apientreprise.svg?branch=master)](https://travis-ci.org/etalab/watchdoge_apientreprise) [![Maintainability](https://api.codeclimate.com/v1/badges/ea09b1d44917a172d01e/maintainability)](https://codeclimate.com/github/etalab/watchdoge_apientreprise/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/ea09b1d44917a172d01e/test_coverage)](https://codeclimate.com/github/etalab/watchdoge_apientreprise/test_coverage)
[![Build Status](https://travis-ci.org/etalab/watchdoge_apientreprise.svg?branch=develop)](https://travis-ci.org/etalab/watchdoge_apientreprise) (develop branch)

Watchdoge is a watchdog for [API Entreprise](https://github.com/etalab/apientreprise), the monitoring done by Watchdoge is available on the [Dashboard](https://github.com/etalab/dashboard_apientreprise)

Watchdoge run on Ruby 2.4.2

# Elasticsearch

The API uses Elasticsearch API, only authorised IP can make requests to Elasticsearch API, add yours for development purpose.

```
sudo ufw allow from <your.ip> to any port 9200 proto tcp
sudo ufw delete allow from <your.ip> to any port 9200 proto tcp
```

You can test your ELK queries in Kibana.

## Configuration

### Database

The database user should exists, it uses PostgreSQL (cf. `config/database.yml`). Execute the following command line to create the default user:

```
sudo -u postgres -i
cd /path/to/watchdoge
psql -f db/init.sql
```

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
Run:

`rspec`

### Regenerate VCR cassettes
`jwt_usage` cassettes are quite hard to regen.

*TL;DR*

1. go to `spec/support/jwt_helper.rb` and replace valid jwt with production watchdoge value
2. delete `spec/cassettes/non_regenerable/jwt_usage.yml`
3. run `rspec spec/controllers/jwt_usage_controller_spec.rb`
4. revert changes in `spec/support/jwt_helper.rb`
5. re-run the tests it should work.
