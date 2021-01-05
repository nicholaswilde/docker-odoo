# Docker Odoo
[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/nicholaswilde/odoo)](https://hub.docker.com/r/nicholaswilde/odoo)
[![Docker Pulls](https://img.shields.io/docker/pulls/nicholaswilde/odoo)](https://hub.docker.com/r/nicholaswilde/odoo)
[![GitHub](https://img.shields.io/github/license/nicholaswilde/docker-odoo)](./LICENSE)
[![yamllint](https://github.com/nicholaswilde/docker-odoo/workflows/yamllint/badge.svg)](https://github.com/nicholaswilde/docker-odoo/actions?query=workflow%3Ayamllint)
[![hadolint](https://github.com/nicholaswilde/docker-odoo/workflows/hadolint/badge.svg)](https://github.com/nicholaswilde/docker-odoo/actions?query=workflow%3Ahadolint)
[![ci](https://github.com/nicholaswilde/docker-odoo/workflows/ci/badge.svg)](https://github.com/nicholaswilde/docker-odoo/actions?query=workflow%3Aci)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

A multi architecture image of [Odoo](https://www.odoo.com/).

# Usage

This image requires a running PostgreSQL server.

## Start a PostgreSQL server

```console
$ docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:10
```

## Start an Odoo instance

```console
$ docker run -p 8069:8069 --name nicholaswilde/odoo --link db:db -t odoo
```

The alias of the container running Postgres must be db for Odoo to be able to connect to the Postgres server.

## Docker Compose examples

The simplest `docker-compose.yml` file would be:

```yml
version: '2'
services:
  web:
    image: odoo:14.0-ls1
    depends_on:
      - db
    ports:
      - "8069:8069"
  db:
    image: postgres:10
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_USER=odoo
```

If the default postgres credentials does not suit you, tweak the environment variables:

```yml
version: '2'
services:
  web:
    image: nicholaswilde/odoo:14.0-ls1
    depends_on:
      - mydb
    ports:
      - "8069:8069"
    environment:
    - HOST=mydb
    - USER=odoo
    - PASSWORD=myodoo
  mydb:
    image: postgres:10
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=myodoo
      - POSTGRES_USER=odoo
```

Here's a last example showing you how to mount custom addons, how to use a custom configuration file and how to use volumes for the Odoo and postgres data dir:

```yml
version: '2'
services:
  web:
    image: nicholaswilde/odoo:14.0
    depends_on:
      - db
    ports:
      - "8069:8069"
    volumes:
      - odoo-web-data:/var/lib/odoo
      - ./config:/etc/odoo
      - ./addons:/mnt/extra-addons
  db:
    image: postgres:10
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_USER=odoo
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - odoo-db-data:/var/lib/postgresql/data/pgdata
volumes:
  odoo-web-data:
  odoo-db-data:
```

To start your Odoo instance, go in the directory of the `docker-compose.yml` file you created from the previous examples and type:

```console
docker-compose up -d
```

## Pre-commit hook

If you want to automatically generate `README.md` files with a pre-commit hook, make sure you
[install the pre-commit binary](https://pre-commit.com/#install), and add a [.pre-commit-config.yaml file](./.pre-commit-config.yaml)
to your project. Then run:

```bash
pre-commit install
pre-commit install-hooks
```
Currently, this only works on `arm64` systems.

## Inspiration

Inspiration for this respository has been taken from [odoo/docker](https://github.com/odoo/docker)

## License

[Apache 2.0 License](./LICENSE)

## Author
This project was started in 2020 by [Nicholas Wilde](https://github.com/nicholaswilde/).
