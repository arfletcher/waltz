# install

# At least one Debian system the default didn't glob correctly
SHELL=/bin/ksh

# Temporary destination
DESTDIR=/tmp/waltz

all:
	@echo Run
	@echo    make DESTDIR=/usr/local/opt/waltz install
	@echo    make DESTDIR=/opt/waltz install

install:
	mkdir -p $(DESTDIR)
	mkdir -p $(DESTDIR)/usr/share/man/man8
	mkdir -p $(DESTDIR)/etc/waltz.d
	rsync -axvH --exclude=/Makefile . $(DESTDIR)
	pod2man usr/sbin/waltz | gzip > $(DESTDIR)/usr/share/man/man8/waltz.8.gz


