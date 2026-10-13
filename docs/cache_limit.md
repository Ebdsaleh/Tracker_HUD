# Tracker_HUD Cache Limit

Tracker_HUD has a shared analysis cache limit setting for large source files.

This setting is intended for all adapters over time, including ASM, Python, Lua, C, and C++.

## Commands

With the default command prefix, use:

```vim
:HudCacheLimit
:HudCacheLimit on
:HudCacheLimit off
:HudCacheLimit 200
```

If `namespace.prefix` is changed in setup, the command name changes with it. For example, a prefix of `TrackerHUD` gives `:TrackerHUDCacheLimit`.

## Meaning

`cache_line_limit` controls the intended bounded pre-read/cache window for large files.

- `on` sets the default cache limit of 200 lines.
- `off` disables the line limit.
- A positive number sets a custom line limit.
- No argument reports the current setting.

## Important distinction

The cache limit does **not** mean the HUD may reveal facts from those cached lines immediately.

Tracker_HUD keeps these two ideas separate:

```text
cache window   = how much source may be pre-read/analyzed early
HUD visibility = what facts are allowed to be displayed at the cursor
```

A fact from source line 80 may be cached while the cursor is on line 1, but it must not be displayed until the cursor reaches line 80 or later.

## Default

The default configuration is:

```lua
analysis = {
    cache_line_limit = 200,
}
```

This is the intended general performance direction for chunky files, especially large ASM listings.

## Current status

The command and shared config/helper are in place. Adapter internals should adopt this policy incrementally and safely. The Python object-model visibility path remains cursor-gated so future model facts are not shown before the cursor reaches them.
