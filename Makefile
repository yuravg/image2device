
MAKE = make --no-print-directory

SCRIPT=image2device
SCRIPT_FNAME=image2device.sh
SCRIPT_VERSION=1.3

BINPREFIX=/usr/local/bin

.PHONY: help install uninstall rpm_lint rpm_clear rpm_build deb_clear deb_lint deb_build

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo ""
	@echo "Usage:  make [target(s)]"
	@echo "where target is any of:"
	@echo ""
	@echo "  install   -  Install the script (to "$(BINPREFIX)")"
	@echo "  uninstall -  Remove the script (from "$(BINPREFIX)")"
	@echo ""
	@echo "  rpm_lint   - Run rpmlint command"
	@echo "  rpm_build  - Build the rpm package"
	@echo ""
	@echo "  deb_lint   - Run rpmlint command"
	@echo "  deb_build  - Build the rpm package"
	@echo ""

install:
	@echo "Installing '$(SCRIPT_FNAME)' ..."
	@chmod 775 "$(SCRIPT_FNAME)"
	@cp -v "$(SCRIPT_FNAME)" "$(BINPREFIX)/$(SCRIPT)"
	@chmod 644 "$(SCRIPT_FNAME)"

uninstall:
	@echo "... uninstalling '$(SCRIPT)'"
	@rm -fv "$(BINPREFIX)/$(SCRIPT)"

rpm_lint:
	rpmlint ./rpmbuild/SPECS/image2device.spec

RPM_DIR="$(SCRIPT)-$(SCRIPT_VERSION)"
rpm_clear:
	rm -rf "$(RPM_DIR)"

PKG_TAR="$(RPM_DIR).tar.gz"
rpm_build:
	@$(MAKE) rpm_clear
	mkdir "$(RPM_DIR)"
	@cp -v "$(SCRIPT_FNAME)" "$(RPM_DIR)"
	@tar -cvzf "$(PKG_TAR)" "$(RPM_DIR)"
	mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	@mv -v "$(PKG_TAR)" rpmbuild/SOURCES
	rpmbuild --define "_topdir `pwd`/rpmbuild" -v -ba ./rpmbuild/SPECS/image2device.spec
	@$(MAKE) rpm_clear

PATH_DEB_PKG=debbuild/"$(SCRIPT)"
DEB_PKG=$(SCRIPT).deb
DEB_PKG_OUT=$(SCRIPT)_$(SCRIPT_VERSION).deb
deb_clear:
	rm -f debbuild/$(DEB_PKG_OUT)

deb_lint:
	lintian debbuild/$(DEB_PKG_OUT)

deb_build:
	@$(MAKE) deb_clear
	mkdir -p $(PATH_DEB_PKG)/bin
	@cp -v $(SCRIPT_FNAME) $(PATH_DEB_PKG)/bin/$(SCRIPT)
	cd debbuild && dpkg-deb --root-owner-group --build $(SCRIPT)
	cd debbuild && mv -v $(DEB_PKG) $(DEB_PKG_OUT)
