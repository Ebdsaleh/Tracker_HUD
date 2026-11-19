"""Tracker_HUD Python with-binding validation sample.

Expected parser-backed binding behavior:
- context-manager aliases become mutable assignment candidates;
- multiple and parenthesized with-items expose one binding per alias;
- async-with aliases use the same binding semantics;
- match/case as-patterns are not context-manager bindings;
- with-binding members remain in source order.
"""


def open_resources(primary_factory, left_factory, right_factory):
    with primary_factory() as handle:
        pass

    with left_factory() as left, right_factory() as right:
        pass

    with (
        left_factory() as wrapped_left,
        right_factory() as wrapped_right,
    ):
        pass

    return handle, left, right, wrapped_left, wrapped_right


async def open_async(async_factory):
    async with async_factory() as stream:
        pass

    return stream


def classify(value):
    match value:
        case ("ok", payload) as matched:
            return matched

    return None
