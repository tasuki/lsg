Strona internetowa Letniej Szkoły Go
====================================

https://lsg.go.art.pl/

Develop
-------

Żeby uruchomić lokalnie, trza zainstalować [Jekylla](https://jekyllrb.com/). Nie używamy zaawansowanych funkcji Jekylla... if you're feeling lucky, może też działać z systemowym.

Bardziej reproducible będzie zainstalować przez Ruby/bundler. W Debianach:

	sudo apt-get install bundler

Potem zainstalować Jekylla:

	bundle install --path vendor/bundle
	bundle exec jekyll serve
