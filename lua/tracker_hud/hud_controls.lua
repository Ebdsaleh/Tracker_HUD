-- lua/tracker_hud/hud_controls.lua
--
-- HUD control registry and runtime control state.

local M = {}

local control_state = {
    show_all_scope_members = false,
}

local controls = {
    {
        id = "show_all_scope_members",
        state_key = "show_all_scope_members",
        enabled_marker = "[+]",
        disabled_marker = "[ ]",
        label = "Show All Scope Members"
    },

}

local function get_control(control_id)
    for _, control in ipairs(controls) do
        if control.id == control_id then
            return control
        end
    end
    return nil
end


function M.toggle(control_id)
    local control = get_control(control_id)
    if not control or not control.state_key then
        return false
    end

    control_state[control.state_key] = not control_state[control.state_key]
    return true
end


function M.is_enabled(control_id)
    local control = get_control(control_id)

    if not control or not control.state_key then
        return false
    end
    
    return control_state[control.state_key] == true
end



function M.build_title(control_id)
    local control = get_control(control_id)

    if not control then
        return nil
    end

    local enabled = control_state[control.state_key] == true
    local marker = enabled and control.enabled_marker or control.disabled_marker

    return marker .. " " .. control.label

end

return M
