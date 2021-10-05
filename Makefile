VERBOSE ?= @

python-packages := python_style tests

.PHONY: check check_black check_isort check_flake8 check_pylint check_mypy check_pydocstyle format test install install_devel install_edge clean

all: check test

check: check_black check_isort check_flake8 check_pylint check_mypy check_pydocstyle

check_black:
	black --check --diff --line-length 100 $(python-packages)

check_isort:
	isort --check --diff $(python-packages)

check_flake8:
	flake8 $(python-packages)

check_pylint:
	pylint $(python-packages)

check_mypy:
	mypy --pretty $(python-packages)

check_pydocstyle:
	pydocstyle $(python-packages)

format:
	black -l 100 $(python-packages)
	isort $(python-packages)

test:
	python3 -m pytest -n$(shell nproc) -vv tests

install:
	pip3 install --force-reinstall .

install_devel:
	pip3 install ".[devel]"

install_devel_edge: install_devel
	pip3 install --upgrade `python -c "from importlib.metadata import requires; print(' '.join(r.split(' ')[0] for r in requires('python-style') if 'devel' in r))"`

clean:
	rm -rf .coverage .mypy_cache .pytest_cache
