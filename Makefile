include Makefile.common

.DEFAULT_GOAL := all

VERBOSE ?= @
SHELL = /bin/bash -o pipefail

PYTHON_PACKAGES := devutils

.PHONY: all

all: check test

.PHONY: install install_devel install_devel_edge test

test:
	./linux/run $(PWD) true; test $$? -eq 0
	./linux/run $(PWD) false; test $$? -eq 1
	./linux/run $(PWD) does_not_exist; test $$? -eq 127
	./linux/run $(PWD) exit 42; test $$? -eq 42
	./linux/run $(PWD) echo EXPECTED_RESULT | grep EXPECTED_RESULT

install:
	pip3 install --force-reinstall .

install_devel:
	pip3 install ".[devel]"

install_devel_edge: install_devel
	tools/upgrade_dependencies.py

.PHONY: clean

clean:
	rm -rf .coverage .mypy_cache .pytest_cache .ruff_cache build
