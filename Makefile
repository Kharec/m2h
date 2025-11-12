PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
PERLLIB = $(PREFIX)/lib/perl5/site_perl
SCRIPT = m2h.pl
TARGET = m2h

.PHONY: all install uninstall test clean tidy help

all:

install: install-bin install-lib

install-bin:
	@mkdir -p $(BINDIR)
	@cp $(SCRIPT) $(BINDIR)/$(TARGET)
	@chmod +x $(BINDIR)/$(TARGET)

install-lib:
	@mkdir -p $(PERLLIB)
	@cp lib/MarkdownParser.pm $(PERLLIB)/

uninstall:
	@rm -f $(BINDIR)/$(TARGET)
	@rm -f $(PERLLIB)/MarkdownParser.pm

test:
	@prove -lr t

clean:
	@rm -f *.html
	@find . -name \*.bak -exec rm -fv {} \;

tidy:
	@perltidy -b $(SCRIPT) lib/MarkdownParser.pm t/*


