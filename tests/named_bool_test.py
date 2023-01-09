import astroid
import pylint.testutils

import devutils.pylint_checker


class TestNamedBooleanArgumentsChecker(pylint.testutils.CheckerTestCase):  # type: ignore[misc]
    CHECKER_CLASS = devutils.pylint_checker.NamedBooleanArgumentsChecker

    def test_valid_calls(self) -> None:
        nodes = astroid.extract_node(
            """
        def test():
            fun1(True) #@
            fun2(arg1=True, arg2=False) #@
            fun3(3) #@
            fun4(7, 12) #@
            fun5("some string", 12) #@
        """
        )

        for n in nodes:
            self.checker.visit_call(n)

    def test_invalid_call_bool(self) -> None:
        call = astroid.extract_node(
            """
        def test():
            fun1 (True, False) #@
        """
        )
        with self.assertAddsMessages(
            pylint.testutils.MessageTest(
                msg_id="C0001",
                node=call.args[0],
                line=3,
                col_offset=10,
                end_line=3,
                end_col_offset=14,
            ),
            pylint.testutils.MessageTest(
                msg_id="C0001",
                node=call.args[1],
                line=3,
                col_offset=16,
                end_line=3,
                end_col_offset=21,
            ),
        ):
            self.checker.visit_call(call)

    def test_invalid_call_mixed(self) -> None:
        call = astroid.extract_node(
            """
        def test():
            fun1 (False, param=True) #@
        """
        )
        with self.assertAddsMessages(
            pylint.testutils.MessageTest(
                msg_id="C0001",
                node=call.args[0],
                line=3,
                col_offset=10,
                end_line=3,
                end_col_offset=15,
            ),
        ):
            self.checker.visit_call(call)
