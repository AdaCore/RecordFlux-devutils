from __future__ import annotations

import argparse
import re
import subprocess
import sys
from collections.abc import Sequence
from dataclasses import dataclass


@dataclass
class Commit:
    identifier: str
    body: list[str]


def parse_commits(log: str) -> list[Commit]:
    commits = []
    identifier: str | None = None
    body: list[str] = []

    for line in log.split("\n"):
        if line.startswith("commit"):
            if identifier:
                commits.append(Commit(identifier, body[1:-1]))
                body = []
            identifier = line.split(" ")[1]
        elif not line or line.startswith("    "):
            body.append(line.strip())

    if identifier:
        commits.append(Commit(identifier, body[1:-1]))

    return commits


def check_commits(commits: Sequence[Commit]) -> list[str]:
    errors = []

    for commit in commits:
        if any(l.startswith(k) for l in commit.body for k in ["fixup", "FIX", "wip", "WIP"]):
            errors.append(f"Fixup commit {commit.identifier}")
        if not any(re.search(r"Ref\. (\S\S*[#!][0-9][0-9]*|None)", l) for l in commit.body):
            errors.append(
                f'No ticket reference of the form "Ref. Project#123" or "Ref. None"'
                f" in commit {commit.identifier}",
            )
        if len(commit.body) > 1 and commit.body[1] != "":
            errors.append(f"No empty line between title and body in commit {commit.identifier}")

    return errors


def git_log(revision_range: str) -> str:
    return subprocess.check_output(
        ["git", "log", revision_range],
        stderr=subprocess.STDOUT,
    ).decode("utf-8")


def main() -> int | str:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "revision_range",
        metavar="REVISION_RANGE",
    )
    args = parser.parse_args(sys.argv[1:])

    log = git_log(args.revision_range)
    commits = parse_commits(log)

    errors = check_commits(commits)
    result = "\n".join(f"error: {e}" for e in errors)

    return result if result else 0
