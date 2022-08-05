# pylint: enable=useless-suppression


class SomeClass:
    def __init__(self, arg1: bool, arg2: bool):
        pass


def func(arg1: bool, arg2: bool) -> bool:
    return arg1 and arg2


def use_func_valid() -> None:
    func(arg1=True, arg2=False)


def use_func_invalid() -> None:
    # As we enable useless supression above, pylinting this function only succeeds if an anonymous
    # boolean argument had been detected below (otherwise we will get a useless supression error).
    # pylint: disable-next=anon-bool-arg
    func(True, False)


def use_class_valid() -> None:
    SomeClass(arg1=True, arg2=False)


def use_class_invalid() -> None:
    # pylint: disable-next=anon-bool-arg
    SomeClass(True, False)
