publish: cals bundle-install
	bundle exec jekyll build

cals:
	python3 calendar/make-cal.py

develop: bundle-install
	(find ./calendar/*.rst | entr python3 ./calendar/make-cal.py &); bundle exec jekyll serve

bundle-install:
	bundle config set --local path 'vendor/bundle'
	bundle install
