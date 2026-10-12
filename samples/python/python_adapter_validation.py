"""Tracker_HUD Python adapter validation sample.

Expected HUD behavior:
- The module should parse without Tree-sitter parser warnings.
- Imports should appear as scope members.
- DemoTracker should appear as a class and own methods.
- __init__ and update should appear as functions/methods.
- Parameters should appear under function scope.
- Assignments should appear as local/member facts.
- if/elif/else, for, try/except, return, raise, and call nodes should be visible.
"""

import math
from pathlib import Path


class DemoTracker:
    def __init__(self, root: Path):
        self.root = root
        self.count = 0

    def update(self, values):
        total = 0

        for value in values:
            if value < 0:
                raise ValueError("negative value")
            elif value == 0:
                total += 1
            else:
                total += math.floor(value)

        try:
            label = self.root.name
        except AttributeError:
            label = "<missing>"

        return label, total


def make_tracker(path_text: str):
    path = Path(path_text)
    tracker = DemoTracker(path)
    return tracker.update([1, 2, 3])


if __name__ == "__main__":
    print(make_tracker("."))
