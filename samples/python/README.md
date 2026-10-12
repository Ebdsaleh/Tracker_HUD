# Tracker_HUD Python Samples

These samples are manual validation fixtures for the Python adapter.

The Python adapter is intended to be the quick, high-confidence high-level-language win after the harder ASM work. The first milestone focuses on source structure and scope/member visibility, not runtime execution or linting.

## Requirements

The Python filetype must have a Tree-sitter parser installed in Neovim. If the HUD only shows a global/empty Python context, install the parser first:

```vim
:TSInstall python
```

Then close and reopen Neovim before validating the sample again.

## Scope model

Tracker_HUD separates two related ideas:

- **Current structural scope** — where the cursor physically is in the nested source layout, such as an `if`, `for`, `try`, function, class, or module.
- **Owning/member scope** — the nearest region that owns the Scope Members tree. In Python this is normally a module, class, or function/method.

For example, inside an `if` nested in `def update`, the HUD should make both facts visible:

- current scope: `If [scope 26 - 31]`
- owning/member scope: `def update(self, values): [scope 22 - 38]`

This is intentional. Python `if`/`for`/`try` blocks matter for navigation and layout, but Python name ownership is still anchored to module/class/function regions.

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
11. On `if`, `elif`, and `else`, Scope should identify the branch structure while Scope Members remains anchored to the owning function/member scope.
12. On `for value in values`, Scope should identify the loop, show the loop variable, and keep function locals visible because Python `for` does not create a new local scope.
13. On `try` and `except`, Scope should identify the nested exception-handling structure while Scope Members remains anchored to the owning function/member scope.
14. On `raise ValueError(...)`, the raise statement should be visible.
15. On `return label, total`, return value information should be visible.
16. On calls such as `Path(path_text)`, `DemoTracker(path)`, `tracker.update(...)`, and `print(...)`, call constructs should be visible.

This sample is not a unit test yet. It is a stable manual HUD validation fixture.
