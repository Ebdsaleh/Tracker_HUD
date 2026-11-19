"""Tracker_HUD Python parameter-binding validation sample.

Expected parser-backed binding behavior:
- positional-only and keyword-only separators are not bindings;
- defaults and annotations preserve the bound identifier;
- *args and **kwargs expose the identifier without splat punctuation;
- parameter members remain in source order.
"""


def route(source, /, count: int = 1, *items: str, enabled: bool = True, **options: object):
    return source


def keyword_only(primary, *, mode: str = "fast", retries=3):
    return primary
