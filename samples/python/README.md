# Tracker_HUD Python Samples

These samples are manual validation fixtures for the Python adapter.

The Python adapter is intended to be the quick, high-confidence high-level-language win after the harder ASM work. The first milestone focuses on source structure and scope/member visibility, not runtime execution or linting.

## Requirements

The Python filetype must have a Tree-sitter parser installed in Neovim. If the HUD only shows a global/empty Python context, install the parser first:

```vim
:TSInstall python
```

Then close and reopen Neovim before validating the sample again.

## Files

- `python_adapter_validation.py` — checks module parsing, imports, classes, functions, methods, parameters, assignments, calls, branches, loops, returns, and raises.

## How to use

Open the sample in Neovim with Tracker_HUD enabled:

```bash
nvim samples/python/python_adapter_validation.py
```

Recommended checks:

1. The HUD should recognize the file as Python with no ASM adapter fallback.
2. The Target line should identify Python rather than unknown low-level target fields.
3. At the top of the file, the scope should be module/global scope.
4. On the module docstring, Scope may show `Module -> String`.
5. On `import math`, Scope Members should show an import member.
6. On `from pathlib import Path`, Scope Members should show a from-import member.
7. On `class DemoTracker`, Scope should show a class construct and Scope Members should show the class.
8. On `def __init__`, Scope should show a function/method construct.
9. On `self`, `root`, and `values` in function signatures, parameters should be visible as scope members.
10. On assignments such as `total = 0`, `label = self.root.name`, and `tracker = DemoTracker(path)`, assignment members should be visible.
11. On `if`, `elif`, and `else`, Scope should identify the nested branch structure.
12. On `for value in values`, Scope should identify the nested loop structure and show the loop variable.
13. On `try` and `except`, Scope should identify the nested exception-handling structure.
14. On `raise ValueError(...)`, the raise statement should be visible.
15. On `return label, total`, return value information should be visible.
16. On calls such as `Path(path_text)`, `DemoTracker(path)`, `tracker.update(...)`, and `print(...)`, call constructs should be visible.

Tracker_HUD intentionally treats Python control-flow blocks such as `if`, `for`, and `try` as structural HUD scopes. This is for navigation and layout awareness. It does not mean Python has C-style block-local variable binding.

This sample is not a unit test yet. It is a stable manual HUD validation fixture.
