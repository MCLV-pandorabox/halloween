-- halloween/storage.lua
-- Persistent storage for Halloween mod settings

local storage = minetest.get_mod_storage()

-- Load global enabled state
function halloween.load_state()
    local enabled = storage:get_string("enabled")
    if enabled == "" then
        halloween.enabled = true  -- default
    else
        halloween.enabled = (enabled == "true")
    end
end

-- Save global enabled state
function halloween.save_enabled(state)
    halloween.enabled = state
    storage:set_string("enabled", tostring(state))
end

-- Load per-disguise enabled flags
function halloween.load_disguise_flags()
    for id, def in pairs(halloween.disguises) do
        local key = "disguise_" .. id:gsub(":", "_")
        local flag = storage:get_string(key)
        if flag ~= "" then
            def.enabled = (flag == "true")
        end
    end
end

-- Set a disguise's enabled flag
function halloween.set_disguise_enabled(id, state)
    if halloween.disguises[id] then
        halloween.disguises[id].enabled = state
        local key = "disguise_" .. id:gsub(":", "_")
        storage:set_string(key, tostring(state))
        return true
    end
    return false
end

-- Initialize on load
halloween.load_state()
