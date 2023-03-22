VERBOSE ?= @
TMPDIR := $(shell mktemp -d)

PYTHON_PACKAGES := devutils tests

.PHONY: all

all: check test

.PHONY: check check_ruff check_black check_isort check_flake8 check_pylint check_mypy check_pydocstyle

check: check_ruff check_black check_isort check_flake8 check_pylint check_mypy check_pydocstyle

check_ruff:
	ruff check $(PYTHON_PACKAGES)

check_black:
	black --check --diff --line-length 100 $(PYTHON_PACKAGES)

check_isort:
	isort --check --diff $(PYTHON_PACKAGES)

check_flake8:
	pflake8 $(PYTHON_PACKAGES)

check_pylint:
	pylint $(PYTHON_PACKAGES)

check_mypy:
	mypy --pretty $(PYTHON_PACKAGES)

check_pydocstyle:
	pydocstyle $(PYTHON_PACKAGES)

.PHONY: format

format:
	ruff check --fix-only $(PYTHON_PACKAGES) | true
	black -l 100 $(PYTHON_PACKAGES)
	isort $(PYTHON_PACKAGES)

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
