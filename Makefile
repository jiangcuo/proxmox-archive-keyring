include /usr/share/dpkg/pkg-info.mk

PACKAGE=proxmox-archive-keyring
BUILDDIR=$(PACKAGE)-$(DEB_VERSION_UPSTREAM)

GITVERSION:=$(shell git rev-parse HEAD)

DEB=$(PACKAGE)_$(DEB_VERSION)_all.deb

all: deb

$(BUILDDIR):
	rm -rf $@ $@.tmp
	mkdir -p $@.tmp/debian
	cp -ar debian/* $@.tmp/debian/
	echo "git clone git://git.proxmox.com/git/proxmox-archive-keyring.git\\ngit checkout $(GITVERSION)" > $@.tmp/debian/SOURCE
	mv $@.tmp $@

deb: $(DEB)
$(DEB): $(BUILDDIR)
	cd $(BUILDDIR); dpkg-buildpackage -b -uc -us
	lintian $(DEB)

.PHONY: upload
upload: $(DEB)
	tar cf - $(DEB)|ssh repoman@repo.proxmox.com -- upload --product pve,pmg,pbs,pbs-client,infra --dist bookworm

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf $(PACKAGE)-[0-9]*/
	rm -f $(PACKAGE)*.tar* *.deb *.dsc *.changes *.build *.buildinfo
