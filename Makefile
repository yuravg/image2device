
MAKE = make --no-print-directory

SCRIPT_NAME=image2device
SCRIPT_VERSION=1.3

SCRIPT=image2device.sh
SCRIPT_OUT=image2device
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
	@echo "Installing '$(SCRIPT)' ..."
	@chmod 775 "$(SCRIPT)"
	@cp -v "$(SCRIPT)" "$(BINPREFIX)/$(SCRIPT_OUT)"
	@chmod 644 "$(SCRIPT)"

uninstall:
	@echo "... uninstalling '$(SCRIPT_OUT)'"
	@rm -fv "$(BINPREFIX)/$(SCRIPT_OUT)"

rpm_lint:
	rpmlint ./rpmbuild/SPECS/image2device.spec

RPM_DIR="$(SCRIPT_NAME)-$(SCRIPT_VERSION)"
rpm_clear:
	rm -rf "$(RPM_DIR)"

PKG_TAR="$(RPM_DIR).tar.gz"
rpm_build:
	@$(MAKE) rpm_clear
	mkdir "$(RPM_DIR)"
	@cp -v "$(SCRIPT)" "$(RPM_DIR)"
	@tar -cvzf "$(PKG_TAR)" "$(RPM_DIR)"
	mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} || true
	@mv -v "$(PKG_TAR)" rpmbuild/SOURCES
	rpmbuild --define "_topdir `pwd`/rpmbuild" -v -ba ./rpmbuild/SPECS/image2device.spec
	@$(MAKE) rpm_clear

deb_clear:
	@echo under design!

deb_lint:
	@echo under design!
	lintian image2device-.deb

deb_build:
	@$(MAKE) deb_clear
	mkdir -p debbuild/{bin,etc,SCRIPT_NAME/DEBIAN} || true
	@cp -v "$(SCRIPT)" debbuild/bin/"$(SCRIPT_OUT)"
	cd debbuild && dpkg-deb --root-owner-group --build "$(SCRIPT_NAME)"
