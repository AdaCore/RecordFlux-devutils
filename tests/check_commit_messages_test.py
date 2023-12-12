import subprocess
import sys
import textwrap

import pytest

import devutils.check_commit_messages
from devutils.check_commit_messages import Commit, check_commits, main, parse_commits


def test_parse_commits() -> None:
    assert parse_commits("") == []
    assert (
        parse_commits(
            textwrap.dedent(
                """\
                    commit 1261c0b9cafcfe58170c21d89191749d21237ba6
                    Author: X
                    Date:   Y

                        Add foo

                        Ref. eng/recordflux/RecordFlux#123

                    commit 5b0398e5707d467a1fe6893d775fd31c89273f73
                    Author: X
                    Date:   Y

                        Change bar
                """,
            ),
        )
        == [
            Commit(
                identifier="1261c0b9cafcfe58170c21d89191749d21237ba6",
                body=["Add foo", "", "Ref. eng/recordflux/RecordFlux#123"],
            ),
            Commit(
                identifier="5b0398e5707d467a1fe6893d775fd31c89273f73",
                body=["Change bar"],
            ),
        ]
    )


def test_check_commits() -> None:
    assert check_commits([]) == []
    assert (
        check_commits(
            [
                Commit("0", ["Add foo", "", "Baz (Ref. eng/recordflux/RecordFlux#123)"]),
                Commit("1", ["Change bar", "", "Ref. None"]),
            ],
        )
        == []
    )
    assert check_commits(
        [
            Commit("1", ["Add foo"]),
        ],
    ) == [
        'No ticket reference of the form "Ref. Project#123" or "Ref. None" in commit 1',
    ]
    assert check_commits(
        [
            Commit("2", ["WIP", "", "Ref. eng/recordflux/RecordFlux#123"]),
        ],
    ) == [
        "Fixup commit 2",
    ]
    assert check_commits(
        [
            Commit("0", ["Add foo", "", "Ref. eng/recordflux/RecordFlux#123"]),
            Commit("1", ["Change bar"]),
            Commit("2", ["WIP", "", "Ref. eng/recordflux/RecordFlux#123"]),
        ],
    ) == [
        'No ticket reference of the form "Ref. Project#123" or "Ref. None" in commit 1',
        "Fixup commit 2",
    ]
    assert check_commits([Commit("4", ["WIP"])]) == [
        "Fixup commit 4",
        'No ticket reference of the form "Ref. Project#123" or "Ref. None" in commit 4',
    ]
    assert check_commits([Commit("5", ["Add foo", "Ref. eng/recordflux/RecordFlux#123"])]) == [
        "No empty line between title and body in commit 5",
    ]


def test_main_no_arg(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(sys, "argv", [""])
    with pytest.raises(SystemExit, match=r"^2$"):
        main()


def test_main(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(sys, "argv", ["", ""])
    monkeypatch.setattr(subprocess, "check_output", lambda _, stderr: b"")  # noqa: ARG005
    main()


def test_main_errors(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(sys, "argv", ["", ""])
    monkeypatch.setattr(devutils.check_commit_messages, "git_log", lambda _: "")
    monkeypatch.setattr(devutils.check_commit_messages, "parse_commits", lambda _: [])
    monkeypatch.setattr(devutils.check_commit_messages, "check_commits", lambda _: ["1", "2"])
    assert main() == "error: 1\nerror: 2"
