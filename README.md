# Strona internetowa Letniej Szkoły Go

https://lsg.go.art.pl/

## Setup

Wymaga Ruby/Bundler. Lepiej Ruby 3 niż 2, ale powinno śmigać na wszystkim.

Na Debian 12 Bookworm można zainstalować następująco:

```
sudo apt-get install bundler
bundle config set --local path 'vendor/bundle'
bundle install
```

Można też użyć Dockera:

```
docker run -p 4000:4000 lsg
```

## Develop

```
make develop
```

## Deploy

GitHub actions robi push na produkcje, gdzie `make publish` robi update.
