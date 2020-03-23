
SCRIPT=image2device.sh
SCRIPT_OUT=image2device
BINPREFIX=/usr/local/bin

.PHONY: install uninstall

default: install

install:
	@echo "Installing '$(SCRIPT)' ..."
	@chmod 775 "$(SCRIPT)"
	@cp -v "$(SCRIPT)" "$(BINPREFIX)/$(SCRIPT_OUT)"
	@chmod 644 "$(SCRIPT)"

uninstall:
	@echo "... uninstalling '$(SCRIPT_OUT)'"
	@rm -fv "$(BINPREFIX)/$(SCRIPT_OUT)"
