"""Tracker_HUD Python for-target binding validation sample.

Expected parser-backed binding behavior:
- destructuring loop targets expose each bound identifier;
- starred loop targets expose the identifier without '*';
- loop-variable members remain in source order.
"""


def iterate(pairs, rows):
    for key, value in pairs:
        pass

    for head, *tail in rows:
        pass
