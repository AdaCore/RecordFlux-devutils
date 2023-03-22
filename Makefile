VERBOSE ?= @
TMPDIR := $(shell mktemp -d)

python-packages := devutils tests

.PHONY: check check_ruff check_black check_isort check_flake8 check_pylint check_mypy check_pydocstyle format test test_unit test_integration install install_devel install_edge clean

all: check test

check: check_ruff check_black check_isort check_flake8 check_pylint check_mypy check_pydocstyle

check_ruff:
	ruff check $(python-packages)

check_black:
	black --check --diff --line-length 100 $(python-packages)

check_isort:
	isort --check --diff $(python-packages)

check_flake8:
	pflake8 $(python-packages)

check_pylint:
	pylint $(python-packages)

check_mypy:
	mypy --pretty $(python-packages)

check_pydocstyle:
	pydocstyle $(python-packages)

format:
	ruff check --fix-only $(python-packages) | true
	black -l 100 $(python-packages)
	isort $(python-packages)

test: test_unit test_integration

test_unit:
	python3 -m pytest -vv tests

$(TMPDIR)/bin/pylint:
	python3 -m venv $(TMPDIR)
	$(TMPDIR)/bin/pip install pylint .[devel]

test_integration: $(TMPDIR)/bin/pylint
	$< tests/data/pylint_boolean_argument_invalid.py

install:
	pip3 install --force-reinstall .

install_devel:
	pip3 install ".[devel]"

install_devel_edge: install_devel
	tools/upgrade_dependencies.py

clean:
	rm -rf .coverage .mypy_cache .pytest_cache
