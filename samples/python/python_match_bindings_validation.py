"""Tracker_HUD Python match-pattern binding validation sample.

Expected parser-backed behavior:
- capture names bind conditionally in the surrounding lexical scope;
- sequence, star, mapping, class, and as-pattern captures are recognized;
- constructor names, keyword labels, and dotted constants are not bindings.
"""


def classify(value):
    match value:
        case ("ok", payload):
            pass

        case [head, *tail]:
            pass

        case {"name": name, **rest}:
            pass

        case Point(x, y=label) as point:
            pass

        case Status.OK:
            pass

        case ("left", item) | ("right", item):
            pass

    return payload, head, tail, name, rest, x, label, point, item
