# Adapter Authoring

Tracker_HUD adapters translate a language's exact Tree-sitter grammar into a
shared semantic vocabulary. The goal is to make an adapter mostly a
description of the language rather than a second implementation of Tracker_HUD.

## The three layers

### 1. Language syntax facts stay in the adapter

Examples:

```text
Python: function_definition.name
Lua:    function_declaration.parameters
C:      function_definition.declarator
C++:    for_range_loop.declarator
```

Node types, field names, token spellings, grammar alternatives, and
language-specific signature patterns are grammar facts. Do not move them into
shared core code.

### 2. Shared programming semantics use Adapter Contract vocabulary

Once syntax is identified, describe what it means:

```text
construct kind
member kind
lexical / structural scope
visibility participation
member ownership
binding / value mutability
value/reference semantics
branch grouping
signature metadata
```

These are the reusable "programming truths" shared by adapters.

### 3. Helpers expand once to plain runtime tables

The authoring helpers are not a cursor-time DSL. They build ordinary Adapter
Contract v1 tables when the adapter module loads.

```text
Tree-sitter grammar facts
        |
        v
construct_schema / scope_member_schema
        |
        v
plain Adapter Contract tables
        |
        v
existing Tracker_HUD runtime
```

## Start here

Copy:

```text
samples/adapter_starter/minimal_adapter.lua
```

Then replace the example grammar names with the exact Tree-sitter names for the
new language.

The starter deliberately demonstrates only four ideas:

1. adapter identity and filetypes;
2. one lexical root construct;
3. one function construct;
4. function and parameter Scope Members.

Add more semantics only when the language actually needs them.

## Construct authoring

Use `construct_schema.rule(...)` when building a table literal, or
`construct_schema.define(...)` when incrementally filling
`adapter.construct_specs`.

Example:

```lua
construct_schema.define(
    M.construct_specs,
    "function_definition",
    "function",
    {
        language_term = "function",
        label = "Function",
        fields = {
            name = "name",
            body = "body",
        },
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    }
)
```

The shared helper knows what a construct/scope/value is. It does **not** know
what `function_definition`, `name`, or `body` mean in a particular grammar.

Current construct authoring slots include:

```text
fields
children
tokens
exclusions
language_term
label
construct_mutability
scope
value
signature
markers
branch
```

## Scope Member authoring

For a simple named binding, use:

```lua
scope_member_schema.named(
    "function_definition",
    "name",
    "function",
    {
        owner_scope = "parent_lexical",
    }
)
```

For richer syntax, use `scope_member_schema.rule(...)`.

Canonical Scope Member groups are:

```text
declarations
assignments
parameters
functions
loops
returns
fields
symbols
```

Do not invent a new group name merely because a language uses a different
word. Map the language syntax to the closest shared semantic concept. If no
shared concept is correct, that is evidence for a contract discussion rather
than a reason to hide language behavior in a custom group.

## Scope policy is semantic, not syntactic

Two languages can use similar syntax while creating different scopes.

For each scoped construct, explicitly answer:

```text
Is this lexical or structural?
Does it affect visibility?
Does it own members?
```

Do not infer those answers from braces, indentation, or node names.

## Values and mutability

Keep these concepts separate:

```text
binding
    Can the name be rebound?

state
    Can the existing value change internally?

shape
    Can fields/members be added or removed?
```

Only declare facts the language guarantees.

## Validation errors are part of the authoring API

Validate the adapter through:

```lua
local contract =
    require("tracker_hud.adapters.contract")

local ok, err =
    contract.validate_adapter(adapter)
```

Errors identify the failing contract path. The automated starter smoke test
locks in examples such as:

```text
adapter.construct_specs[function_definition].construct.kind ...
adapter.construct_specs[function_definition].scope.kind ...
adapter.scope_members.functions[1].member.owner_scope ...
```

Fix the declared fact at that path rather than adding runtime workarounds.

## When shared core should grow

Do not add a shared abstraction just because one language can use it.

Promote something into shared vocabulary when multiple real adapters need the
same semantic concept and the concept is language-independent.

Good candidate:

```text
"a construct owns a lexical member scope"
```

Bad candidate:

```text
"Python for_statement.left means the loop variable"
```

The latter belongs in the Python adapter.

## Validation workflow

Normal ERIDU validation remains:

```bat
tracker_full.bat
tracker_profile.bat
```

The executable starter is covered by the cumulative test suite, so changes to
the Adapter Contract cannot silently make this guide stale.
