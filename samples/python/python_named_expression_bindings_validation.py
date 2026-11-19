"""Tracker_HUD Python named-expression binding validation sample.

Expected parser-backed binding behavior:
- assignment expressions bind their declared name;
- bindings are collected from if, while, and return expression contexts;
- members remain in source order;
- raw ':=' expression text is never exposed as the binding name.
"""


def consume(source, reader):
    if (captured := source):
        pass

    while (chunk := reader()):
        break

    return (final := captured)
