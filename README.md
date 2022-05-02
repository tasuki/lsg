Strona internetowa Letniej Szkoły Go
====================================

https://lsg.go.art.pl/

Setup
-----

Wymaga Ruby/Bundler (na Jekylla), reStructuredText (na budowę kalendarza), oraz BeautifulSoup (na post-processing kalendarza).

Na Debianach można zainstalować następująco:

	sudo apt-get install bundler python3-docutils python3-bs4
	bundle install --path vendor/bundle

Develop
-------

Kalendarz robi reStructuredText z rzeczy w `calendar/`, jekyll servuje. Wszystko można uruchomić:

	make develop

Deploy
------

GitHub actions robi push na produkcje, gdzie `make publish` robi update.
