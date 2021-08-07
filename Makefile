# Create packages

NAME:=$(shell basename $$(pwd) )

VER := $(shell sed -n -e 's/^Version:[[:space:]]*//p' $(NAME).spec )
REL := $(shell sed -n -e 's/^Release:[[:space:]]*//p' $(NAME).spec )
DREL = 2
SOURCES := $(shell sed -n -e 's/^Source[^:]*:[[:space:]]*//p' $(NAME).spec )

all: tgz rpm deb

FILES := $(shell find src -type f)

tgz: $(NAME)-$(VER)-$(REL).tgz
	@ls -al $<

$(NAME)-$(VER)-$(REL).tgz: ${FILES}
	fakeroot tar '--transform=s!^src/!$(NAME)-$(VER)/!' -zcf $@ $^

#rpm: $(NAME)-$(VER)-$(REL).src.rpm $(NAME)-$(VER)-$(REL).noarch.rpm
rpm: $(NAME)-$(VER)-$(REL).noarch.rpm
	@ls -al *.rpm

$(NAME)-$(VER)-$(REL).noarch.rpm: $(NAME).spec ${FILES}
	rpmbuild -ba $(NAME).spec | tee $<.log
	@mv -v $$(sed -n -e 's/^Wrote: //p' $<.log) .
	rm $<.log

$(NAME)_$(VER)-$(DREL)_all.deb: $(NAME)-$(VER)-$(REL).noarch.rpm
	fakeroot alien --to-deb $<

deb: $(NAME)_$(VER)-$(DREL)_all.deb
	@ls -al $<

.PHONY: tgz deb rpm clean old all


##############################################################################
X$(NAME)-$(VER)-$(REL).deb: tgz
	# stage the package
	rm -fr tmp
	mkdir -p tmp
	#cd tmp && tar --strip-components=1 -xvf ../$(NAME)-$(VER)-$(REL).tgz
	cd tmp && tar vzxf ../$(NAME)-$(VER)-$(REL).tgz
	cd tmp/$(NAME)-$(VER) && make install DESTDIR=.. SYSDIR=/etc/default
	$(RM) -r tmp/$(NAME)-$(VER)
	rsync -axvHP DEBIAN tmp
	(cd tmp && md5sum $$(find etc usr -type f) > DEBIAN/md5sums)
	fakeroot dpkg-deb --build `pwd`/tmp .
	rm -r tmp
##############################################################################

clean:
	$(RM) -r BUILD  BUILDROOT  RPMS  SPECS  SRPMS *.log tmp

distclean: clean
	$(RM) *.rpm *.tgz *.deb

FORCE:
old: FORCE
	@mkdir -pv old
	mv -vit old *.rpm *.deb *.tgz

