publish: cals
	bundle exec jekyll build
cals:
	python3 calendar/make-cal.py
develop:
	(find ./calendar/*.rst | entr python3 ./calendar/make-cal.py &); bundle exec jekyll serve
