# README [![Build Status](https://travis-ci.org/etalab/watchdoge_apientreprise.svg?branch=master)](https://travis-ci.org/etalab/watchdoge_apientreprise) [![Maintainability](https://api.codeclimate.com/v1/badges/ea09b1d44917a172d01e/maintainability)](https://codeclimate.com/github/etalab/watchdoge_apientreprise/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/ea09b1d44917a172d01e/test_coverage)](https://codeclimate.com/github/etalab/watchdoge_apientreprise/test_coverage)
[![Build Status](https://travis-ci.org/etalab/watchdoge_apientreprise.svg?branch=develop)](https://travis-ci.org/etalab/watchdoge_apientreprise) (develop branch)

Watchdoge is a watchdog for [API Entreprise](https://github.com/etalab/apientreprise), the monitoring done by Watchdoge is available on the [Dashboard](https://github.com/etalab/dashboard_api_entreprise)

Watchdoge run on Ruby 2.6.2

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

And

```
bundle exec rails db:create:all
bundle exec rails db:migrate RAILS_ENV=<desired_env>
```

### Development environment

Run:

`rake dev:init`

It will init the development environement (defaults config files & database)

## Add new API to test

Add a block in `app/data/endpoints.yml` following this schema (have a look to existing and test with rake) :

```yml
- uname: <unique name>
  name: <display name>
  api_name: <apie or sirene>
  provider: <provider name only relevant for apie>
  api_version: <no more used because v1 is deprecated>
  ping_period: <period between pings in minutes>
  http_path: <http path following the base url>
  http_query: <json of http query params if needed>
```

## Rake tasks

You will need to fill `config/secrets.yml` with valid jwt for each `RAILS_ENV` you'd like to run the tasks.

Run the main job in a rake task and get debug info (specify RAILS_ENV):

`rake watch:all`

Can run only one endpoint (specify RAILS_ENV):

`rake watch_v2:one apie_2_attestations_sociales_acoss`

Can run only one API :

```
bundle exec rake watch:apie
bundle exec rake watch:sirene
bundle exec rake watch:rna
bundle exec rake watch:data.gouv.fr
```

## Deployment

Run:

`mina deploy domain=<MY IP> to=<development|production>`

## Dependencies
Needs PostgreSQL installed,  certifcates (and IP whitelist) for API Entreprise and it's providers

## Services
Watchdoge use `whenever` to perform periodic pings. Mina updates crontab on deployment.

## Tests
Run:

`bundle exec rspec`

Very long tests :

`bundle exec rspec --tag very_long_test`
