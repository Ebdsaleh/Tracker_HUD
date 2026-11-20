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

## External adapters are drop-in modules

A new adapter does not need an edit to Tracker_HUD's registry.

Put its entry point under any runtimepath-backed module prefix using this shape:

```text
lua/
  my_tracker_adapters/
    my_language/
      init.lua
```

The `init.lua` file returns the Adapter Contract table.

Then include both Tracker_HUD's built-in adapter path and the custom path during
setup:

```lua
require("tracker_hud").setup({
    adapter_paths = {
        "tracker_hud/adapters",
        "my_tracker_adapters",
    },
})
```

Tracker_HUD scans each configured prefix for:

```text
lua/<adapter_path>/*/init.lua
```

and registers the adapter under every filetype declared by that module.

A broken custom adapter does not prevent other discovered adapters from loading.
Tracker_HUD warns with the module name plus the exact Contract v1 error path.
`setup()` also returns the loader result for programmatic checks:

```lua
local result =
    require("tracker_hud").setup({
        adapter_paths = {
            "tracker_hud/adapters",
            "my_tracker_adapters",
        },
    })

-- result.loaded_count
-- result.errors
```

This means adapter #5 can live outside the Tracker_HUD repository. The core
registry, loader, and context engine do not need language-specific edits.

## Discover the grammar before writing declarations

Do not guess Tree-sitter node types or field names from source-language syntax.

Open a small representative source file with the parser installed, then use
Neovim's built-in Tree-sitter inspection tools.

### Interactive tree view

Run:

```vim
:InspectTree
```

This opens the parsed syntax tree for the current buffer. In the tree window:

```text
a       toggle anonymous nodes/tokens
<Enter> jump between a tree node and its source
zo / zc expand or collapse tree folds
```

Anonymous nodes matter because literal grammar tokens such as `function`,
`(`, `)`, `:`, `end`, or `=` may become Adapter Contract markers.

### Parser vocabulary

For the current filetype, inspect the parser metadata:

```lua
local lang =
    vim.treesitter.language.get_lang(
        vim.bo.filetype
    )

print(
    vim.inspect(
        vim.treesitter.language.inspect(
            lang
        )
    )
)
```

This is useful for checking that a proposed node or field name actually exists
in the installed grammar.

### Inspect exact child fields

When a construct is still ambiguous, inspect the real node rather than
inventing a field mapping:

```lua
local node =
    vim.treesitter.get_node({
        include_anonymous = true,
    })

for child, field_name in node:iter_children() do
    local sr, sc, er, ec =
        child:range()

    print(
        tostring(field_name or "-"),
        child:type(),
        child:named(),
        sr,
        sc,
        er,
        ec,
        vim.treesitter.get_node_text(
            child,
            0
        )
    )
end
```

The adapter authoring questions then become mechanical:

```text
What node type represents the construct?
Which named child carries the name?
Which field carries parameters/body/value?
Which anonymous tokens mark the construct?
Does the language give this construct lexical or structural scope?
What shared construct/member kind describes its meaning?
```

The first four answers come from the parser. The last two are semantic decisions
that belong in the adapter.

The cumulative test suite exercises this workflow against Neovim's bundled Lua
parser so the documented node/field/token inspection assumptions cannot drift
silently.

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

## Check adapter readiness in the current buffer

After installing the parser and placing the adapter on runtimepath, run:

```vim
:HudAdapterStatus
```

The command follows the same public namespace prefix as the other Tracker_HUD
commands, so a custom prefix such as `Tutor` produces
`:TutorAdapterStatus`.

The diagnostic checks the current buffer in dependency order:

```text
filetype known?
Tree-sitter language resolved?
parser available?
root syntax node available?
adapter registered for this filetype?
registered adapter still Contract v1 valid?
```

A healthy buffer ends with:

```text
[READY] adapter pipeline is ready
```

A failure stops being a vague "HUD does not work" problem. Fix the first
missing or invalid item in the report, then run the command again.

This diagnostic is on-demand authoring tooling. It does not run during normal
cursor refreshes and adds no hot-path parser or validation work.

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

## Adapter-owned target dimensions and version bundles

Tracker_HUD does not impose one universal user-facing `variant` vocabulary
on every adapter. The **selection mechanism is generic, but its terminology
is adapter-owned**.

Examples:

- C++ uses `standard` for C++98/C++11/C++17/C++20 because that is the
  ecosystem's normal nomenclature.
- ASM uses `variant` for processor/ISA selections such as i386, x86_64,
  m68000 or SH-4; `platform` remains a separate Windows/Linux/console
  environment dimension.
- Parser capability does not authorize semantics from a later language
  standard or different ISA variant.

The built-in C++ design intends `cpp17` to be the default standard while
allowing explicit regression to older standards such as C++98 and future
advancement to C++20/23 through composed semantic bundles.

See [Adapter target dimensions and language-version bundles](adapter_target_dimensions.md)
for the locked terminology, availability, bundle, cache-identity, and
compatibility rules. That document is architectural intent; do not assume
every described directive/dimension is implemented yet.

