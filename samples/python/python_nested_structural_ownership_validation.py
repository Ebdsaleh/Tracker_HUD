"""Tracker_HUD Python nested structural ownership validation sample.

Expected parser-backed behavior:
- nested structural scopes accumulate independently of lexical depth;
- while -> with -> match -> case reaches structural depth 4;
- every binding remains in the surrounding function lexical namespace.
"""


def nested_structures(source, manager, value):
    while source:
        outer_seen = source
        with manager() as handle:
            managed = handle
            match value:
                case ("ok", payload):
                    nested = payload
                    break
        break

    return outer_seen, handle, managed, payload, nested
