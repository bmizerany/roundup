.POSIX:
SHELL = /bin/sh
RM = rm
CP = cp
CD = cd

# The default target ...
all::

config.mk:
	@echo "Please run ./configure before running make"
	exit 1

include config.mk

sourcedir = .
PROGRAMS = roundup
DISTFILES = config.mk config.sh

RONNS = $(wildcard *.ronn)
ROFFS = $(RONNS:.ronn=)

SCRIPTS = roundup.sh $(wildcard *-test.sh)
CODE_DOCS = $(SCRIPTS:=.html)
MAN_DOCS = $(RONNS:.ronn=.html)
DOCS = index.html $(CODE_DOCS) $(MAN_DOCS)

all:: sup build

sup:
	echo "==========================================================="
	head -7 < README
	echo "==========================================================="

build: roundup
	echo "roundup built at \`$(sourcedir)/roundup' ..."
	echo "run \`make install' to install under $(bindir) ..."
	echo "or, just copy the \`$(sourcedir)/roundup' file where you need it."

roundup: roundup.sh FORCE
	$(SHELL) -n roundup.sh
	sed "s~#!/bin/sh~#!${SHELL}~" roundup.sh > roundup
	chmod 0755 roundup

test: roundup
	@echo This is expected to fail \`make\`.
	@echo
	./roundup

doc: $(DOCS)

%.sh.html: %.sh
ifdef SHOCCO
	$(SHOCCO) $< > $@
endif

$(MAN_DOCS): $(RONNS)
ifdef RONN
	$(RONN) -W5 -s toc $?
else
	@echo "Unable to find ronn to recompile man pages;  Skipping man page docs."
endif

man: $(ROFFS)

$(ROFFS): $(RONNS)
ifdef RONN
	ronn -Wr $?
else
	@echo Unable to find ronn to recompile man pages.
	@echo See http://bmizerany.github.com/roundup for install instructions
	exit 1
endif

install: $(INSTALL_PREREQUISITES)
	test -f roundup
	mkdir -p "$(bindir)"
	cp roundup "$(bindir)/roundup"
	chmod 0755 $(bindir)/roundup

install-man: man
	-for i in {1..9} ; do cp *.$$i $(mandir)/man$$i 2>/dev/null ; done

.PHONY: pages
pages : doc
	-$(RM) -rf pages
	$(GIT) fetch -q origin
	$(GIT) branch -f gh-pages origin/gh-pages
	$(GIT) clone -q -o local -b gh-pages . pages
	$(CP) $(DOCS) $(PWD)/pages
	$(CP) Pages.mk pages/Makefile
	$(CD) pages && $(MAKE) $(MFLAGS) all

read: sup doc
	$(BROWSER) ./roundup.html

clean:
	$(RM) -rf $(PROGRAMS) $(CODE_DOCS) $(MAN_DOCS) $(ROFFS) pages/

distclean: clean
	$(RM) -rf $(DISTFILES)

.PHONY: FORCE

.SUFFIXES:

.SILENT: build sup roundup test
