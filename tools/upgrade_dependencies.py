#!/usr/bin/env python3

"""Upgrade all development dependencies."""

import sys
from subprocess import call

if sys.version_info >= (3, 8):
    from importlib.metadata import requires
else:
    from importlib_metadata import requires

DEPENDENCIES = " ".join(r.split(" ")[0] for r in (requires("RecordFlux-devutils") or []) if "devel" in r)

call(f"pip3 install --upgrade {DEPENDENCIES}", shell=True)
