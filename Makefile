SHELL = /bin/bash
TARGET ?= /usr/bin

.PHONY: help
help:
	@echo "Install or remove the just task runner package."
	@echo
	@echo "    Install just: make install"
	@echo "     Remove just: make remove"

.PHONY: install
install:
	@if [ ! -f $(TARGET)/just ] ; then \
		echo "Installing 'just' to $(TARGET)..." ; \
		curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to $(TARGET) ; \
	else \
		echo "$(TARGET)/just already installed" ; \
	fi

.PHONY: remove
remove:
	@if [ ! -f $(TARGET)/just ] ; then \
		echo "$(TARGET)/just not installed" ; \
	else \
		sudo rm $(TARGET)/just ; \
	fi
