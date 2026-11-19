"""Tracker_HUD Python lambda-scope validation sample.

Expected parser-backed behavior:
- lambda parameters belong to the lambda lexical scope;
- rich parameter forms normalize to their bound identifiers;
- nested lambdas create a deeper lexical owner for inner parameters.
"""


simple = lambda value: value

rich = lambda source, count=1, *items, enabled=True, **options: (
    source,
    count,
    items,
    enabled,
    options,
)

nested = (
    lambda outer: (
        lambda inner: outer + inner
    )
)
