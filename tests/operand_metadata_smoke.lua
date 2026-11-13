-- tests/operand_metadata_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/operand_metadata_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local metadata =
    require("tracker_hud.low_level.operand_metadata")

assert(metadata.format_role_label(
        "source_address"
    ) == "source address"
    and metadata.format_role_label(nil) == nil,
    "operand role labels changed")
print("PASS operand metadata: role labels preserved")

assert(metadata.kind_label("integer")
        == "immediate"
    and metadata.kind_label(
        "memory_component"
    ) == "memory component"
    and metadata.kind_label(nil) == nil,
    "operand kind labels changed")
print("PASS operand metadata: kind labels preserved")

assert(metadata.value_source_label({
        kind = "integer",
        text = "60",
    }) == "immediate 60"
    and metadata.value_source_label({
        kind = nil,
        text = "msg",
    }) == "msg"
    and metadata.value_source_label({}) == nil,
    "value-source labels changed")
print("PASS operand metadata: value-source labels preserved")

assert(metadata.memory_size_label({
        label = "qword",
        bits = 64,
    }) == "qword (64-bit)"
    and metadata.memory_size_label({
        prefix = "dword",
        bits = 32,
    }) == "dword (32-bit)"
    and metadata.memory_size_label({
        bits = 16,
    }) == "memory (16-bit)"
    and metadata.memory_size_label(nil)
        == nil,
    "memory-size labels changed")
print("PASS operand metadata: memory-size labels preserved")

local address = {
    address_mode = "relative",
    address_size_bits = 32,
    address_size_status = "known",
    address_size_source = "explicit_prefix",
    address_size_reason = nil,
    base = {
        name = "rip",
    },
    index = {
        name = "rax",
    },
    scale = {
        value = "4",
    },
    displacement = {
        value = "-8",
    },
    symbol = {
        name = "msg",
    },
}

local operand = {
    kind = "memory",
    text = "qword [rip + rax*4 + msg - 8]",
    memory = {
        address_text =
            "rip + rax*4 + msg - 8",
        address_kind = "bracketed",
        size = {
            prefix = "qword",
            bits = 64,
        },
        normalized = address,
        components = {
            {
                kind = "register",
                text = "rip",
                role = "base",
                role_label = "base register",
            },
            {
                kind = "register",
                text = "rax",
                role = "index",
                role_label = "index register",
            },
            {
                kind = "integer",
                text = "4",
                role = "scale",
            },
            {
                kind = "symbol",
                text = "msg",
                role = "symbol",
            },
            {
                kind = "integer",
                text = "-8",
                role = "displacement",
            },
        },
    },
}

local operand_metadata = {}

metadata.append_memory_operand(
    operand_metadata,
    operand
)

assert(operand_metadata.containing_operand
        == operand.text
    and operand_metadata.containing_operand_kind
        == "memory"
    and operand_metadata.containing_operand_kind_label
        == "memory operand"
    and operand_metadata.memory_address
        == "rip + rax*4 + msg - 8"
    and operand_metadata.memory_address_kind
        == "bracketed"
    and operand_metadata.memory_size
        == "qword (64-bit)"
    and operand_metadata.memory_size_bits == 64
    and operand_metadata.memory_size_prefix
        == "qword",
    "memory operand container metadata changed")
print("PASS operand metadata: memory container fields preserved")

assert(operand_metadata.memory_address_structured
        == address
    and operand_metadata.memory_address_mode
        == "relative"
    and operand_metadata.memory_address_size_bits
        == 32
    and operand_metadata.memory_address_size_status
        == "known"
    and operand_metadata.memory_address_size_source
        == "explicit_prefix"
    and operand_metadata.memory_base_register
        == "rip"
    and operand_metadata.memory_index_register
        == "rax"
    and operand_metadata.memory_scale == "4"
    and operand_metadata.memory_displacement
        == "-8"
    and operand_metadata.memory_symbol == "msg",
    "structured memory-address metadata changed")
print("PASS operand metadata: normalized address fields preserved")

assert(operand_metadata.memory_address_components
        == "base register: rip, index register: rax, scale: 4, symbol: msg, displacement: -8",
    "memory component summary ordering changed")
print("PASS operand metadata: component summary preserved")

local component_metadata = {}

metadata.append_memory_component(
    component_metadata,
    operand,
    {
        kind = "integer",
        text = "-8",
        role = "source_displacement",
        structural_role = "displacement",
    }
)

assert(component_metadata.containing_operand
        == operand.text
    and component_metadata.focused_token
        == "-8"
    and component_metadata.focused_token_kind
        == "immediate"
    and component_metadata.address_role
        == "source displacement"
    and component_metadata.address_role_id
        == "displacement"
    and component_metadata.address_display_role_id
        == "source_displacement"
    and component_metadata.value_source
        == "memory qword [rip + rax*4 + msg - 8]"
    and component_metadata.value_source_text
        == operand.text
    and component_metadata.value_source_kind
        == "memory",
    "focused memory-component metadata changed")
print("PASS operand metadata: focused component fields preserved")

local untouched = {
    sentinel = true,
}

metadata.append_memory_operand(
    untouched,
    {}
)
metadata.append_memory_component(
    untouched,
    operand,
    nil
)

assert(untouched.sentinel == true
    and untouched.containing_operand == nil
    and untouched.focused_token == nil,
    "invalid operand/component metadata must fail closed")
print("PASS operand metadata: invalid inputs fail closed")

print("PASS Tracker_HUD operand-metadata smoke")
