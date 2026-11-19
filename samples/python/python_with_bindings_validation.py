"""Tracker_HUD Python with-binding validation sample.

Expected parser-backed binding behavior:
- context-manager aliases become mutable assignment candidates;
- multiple with-items expose one binding per alias;
- with-binding members remain in source order.
"""


def open_resources(primary_factory, left_factory, right_factory):
    with primary_factory() as handle:
        pass

    with left_factory() as left, right_factory() as right:
        pass

    return handle, left, right
