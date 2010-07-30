include ../config.mk

all :
	$(GIT) add .
	$(GIT) commit -q -m 'rebuild manual'
	$(GIT) push local gh-pages
