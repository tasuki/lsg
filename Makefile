publish: bundle-install
	bundle exec jekyll build

develop: bundle-install
	bundle exec jekyll serve

bundle-install:
	bundle config set --local path 'vendor/bundle'
	bundle install
