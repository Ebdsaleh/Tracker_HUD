# Tracker_HUD Python Samples

These samples are manual validation fixtures for the Python adapter.

The Python adapter is intended to be the quick, high-confidence high-level-language win after the harder ASM work. The first milestone focuses on source structure and scope/member visibility, not runtime execution or linting.

## Files

- `python_adapter_validation.py` — checks module parsing, imports, classes, functions, methods, parameters, assignments, calls, branches, loops, returns, and raises.

## How to use

Open the sample in Neovim with Tracker_HUD enabled:

```bash
nvim samples/python/python_adapter_validation.py
```

Recommended checks:

1. The HUD should recognize the file as Python with no ASM adapter fallback.
2. At the top of the file, the scope should be module/global scope.
3. On `import math`, Scope Members should show an import member.
4. On `from pathlib import Path`, Scope Members should show a from-import member.
5. On `class DemoTracker`, Scope should show a class construct and Scope Members should show the class.
6. On `def __init__`, Scope should show a function/method construct.
7. On `self`, `root`, and `values` in function signatures, parameters should be visible as scope members.
8. On assignments such as `total = 0`, `label = self.root.name`, and `tracker = DemoTracker(path)`, assignment members should be visible.
9. On `if`, `elif`, and `else`, Scope should identify the branch structure.
10. On `for value in values`, Scope should identify the loop and show the loop variable.
11. On `raise ValueError(...)`, the raise statement should be visible.
12. On `return label, total`, return value information should be visible.
13. On calls such as `Path(path_text)`, `DemoTracker(path)`, `tracker.update(...)`, and `print(...)`, call constructs should be visible.

This sample is not a unit test yet. It is a stable manual HUD validation fixture.
