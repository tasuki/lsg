Strona internetowa Letniej Szkoły Go
====================================

https://lsg.go.art.pl/

Setup
-----

Kiedyś było GitHub pages, otóż już jest bardziej skomplikowane...

Wymaga Ruby/Bundler oraz reStructuredText. Na Debianach można zainstalować następująco:

	sudo apt-get install bundler python3-docutils python3-bs4

Potem zainstalować Jekylla:

	bundle install --path vendor/bundle
	bundle exec jekyll serve

Develop
-------

Bardziej reproducible będzie zainstalować przez Ruby/bundler. W Debianach:

	sudo apt-get install bundler

Potem zainstalować Jekylla:

	bundle install --path vendor/bundle
	bundle exec jekyll serve
