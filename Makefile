include Makefile.common

VERBOSE ?= @
TMPDIR := $(shell mktemp -d)

PYTHON_PACKAGES := devutils tests

.PHONY: all

all: check test

.PHONY: test test_unit test_integration

test: test_unit test_integration

test_unit:
	python3 -m pytest -vv tests

$(TMPDIR)/bin/pylint:
	python3 -m venv $(TMPDIR)
	$(TMPDIR)/bin/pip install pylint .[devel]

test_integration: $(TMPDIR)/bin/pylint
	$< tests/data/pylint_boolean_argument_invalid.py

.PHONY: install install_devel install_devel_edge

install:
	pip3 install --force-reinstall .

install_devel:
	pip3 install ".[devel]"

install_devel_edge: install_devel
	tools/upgrade_dependencies.py

.PHONY: clean

clean:
	rm -rf .coverage .mypy_cache .pytest_cache
