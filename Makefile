include Makefile.common

.DEFAULT_GOAL := all

VERBOSE ?= @

PYTHON_PACKAGES := devutils tests

.PHONY: all

all: check test

.PHONY: test test_unit test_integration

test: test_unit test_integration

test_unit:
	python3 -m pytest -vv tests

test_integration:
	python3 -m venv --clear build/venv
	build/venv/bin/pip install pylint ".[devel]"
	build/venv/bin/pylint tests/data/pylint_boolean_argument_invalid.py

.PHONY: install install_devel install_devel_edge

install:
	pip3 install --force-reinstall .

install_devel:
	pip3 install ".[devel]"

install_devel_edge: install_devel
	tools/upgrade_dependencies.py

.PHONY: clean

clean:
	rm -rf .coverage .mypy_cache .pytest_cache .ruff_cache build
