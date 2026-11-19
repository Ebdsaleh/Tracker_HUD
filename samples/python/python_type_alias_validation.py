"""Tracker_HUD Python type-alias binding validation sample.

Expected parser-backed behavior:
- type statements bind the alias name in the current lexical scope;
- generic type parameters are not ordinary alias bindings;
- a function-local type alias remains function-local.
"""


type UserId = int
type Pair[T] = tuple[T, T]


def make_alias():
    type LocalMap[K, V] = dict[K, V]
    return LocalMap
