DESTDIR =
PREFIX  = /usr
LIBDIR  = $(DESTDIR)$(PREFIX)/lib
MANDIR  = $(DESTDIR)$(PREFIX)/share/man/man1
DOCDIR  = $(DESTDIR)$(PREFIX)/share/doc

all: man

.PHONY: clean

lib = log4sh
libs = $(addprefix doc/, $(lib))

%.1: %.pod
	pod2man $< > $@

%.txt: %.pod
	pod2text $< > $@

%.wiki: %.pod
	pod2wiki --style markdown $< > $@

# generate doc/$lib.{txt,1,wiki}
doc: $(addsuffix .txt, $(addprefix doc/, $(lib) ) )

man: $(addsuffix .1, $(addprefix doc/, $(lib) ) )

wiki: $(addsuffix .wiki, $(addprefix doc/, $(lib)))

install: all
	$(foreach _lib,$(lib), \
		install -Dm644 doc/$(_lib).txt $(DOCDIR)/$(_lib).txt; \
		install -Dm644 doc/$(_lib).1 $(MANDIR)/$(_lib).1; \
		install -Dm644 $(_lib).sh $(LIBDIR)/$(_lib).sh; \
	)

clean:
	$(foreach _lib,$(lib), \
		$(RM) doc/$(_lib).1; \
		$(RM) doc/$(_lib).txt; \
		$(RM) doc/$(_lib).wiki; \
	)
