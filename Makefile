include Makefile.common

.DEFAULT_GOAL := all

VERBOSE ?= @

PYTHON_PACKAGES := devutils

.PHONY: all

all: check

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
