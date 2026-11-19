"""Tracker_HUD Python structural-block validation sample.

Expected parser-backed behavior:
- while, with, and match are structural HUD scopes, not Python namespaces;
- assignments inside those blocks stay in the surrounding function lexical scope;
- with aliases remain ordinary function-local bindings.
"""


def structural_blocks(source, manager, value):
    while source:
        loop_seen = source
        break

    with manager() as handle:
        managed = handle

    match value:
        case "ok":
            matched = value

    return loop_seen, managed, matched
