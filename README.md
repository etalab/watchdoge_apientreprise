# README

Watchdoge is a watchdog for [API Entreprise](https://github.com/etalab/apientreprise), the monitoring done by Watchdoge is available on the [Dashboard](https://github.com/etalab/dashboard_apientreprise)

Watchdoge run on Ruby 2.4.2

master: [![Build Status](https://travis-ci.org/etalab/watchdoge_apientreprise.svg?branch=master)](https://travis-ci.org/etalab/watchdoge_apientreprise)
 
develop: [![Build Status](https://travis-ci.org/etalab/watchdoge_apientreprise.svg?branch=develop)](https://travis-ci.org/etalab/watchdoge_apientreprise)

# Elasticsearch

The API uses Elasticsearch API, only authorised IP can make requests to Elasticsearch API, add yours for development purpose.

```
sudo ufw allow from <your.ip> to any port 9200 proto tcp
sudo ufw delte allow from <your.ip> to any port 9200 proto tcp
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
