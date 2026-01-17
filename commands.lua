-- halloween/commands.lua
-- Chat commands and privileges

-- Register admin privilege
minetest.register_privilege("halloween_admin", {
    description = "Manage Halloween disguises and settings",
    give_to_singleplayer = false,
})

-- Player command: List available disguises
minetest.register_chatcommand("halloween_list", {
    description = "List available disguises",
    params = "[filter]",
    func = function(name, param)
        if not halloween.is_enabled() then
            return false, "Halloween mode is currently disabled."
        end
        
        local list = halloween.list_disguises(param ~= "" and param or nil)
        
        if #list == 0 then
            return true, "No disguises available."
        end
        
        local names = {}
        for _, entry in ipairs(list) do
            table.insert(names, entry.id)
        end
        
        return true, string.format("%d disguises: %s", #list, table.concat(names, ", "))
    end,
})

-- Player command: Disguise as mob/entity
minetest.register_chatcommand("halloween_disguise", {
    description = "Disguise as a mob or entity",
    params = "<id>",
    func = function(name, param)
        if param == "" then
            return false, "Usage: /halloween_disguise <id>"
        end
        
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end
        
        local success, msg = halloween.set_disguise(player, param)
        if success then
            return true, "Disguised as: " .. param
        else
            return false, msg or "Failed to set disguise."
        end
    end,
})

-- Player command: Clear disguise
minetest.register_chatcommand("halloween_clear", {
    description = "Remove your current disguise",
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end
        
        halloween.clear_disguise(player)
        return true, "Disguise removed."
    end,
})

-- Admin command: Toggle Halloween mode
minetest.register_chatcommand("halloween_toggle", {
    description = "Enable or disable Halloween mode",
    params = "on|off",
    privs = {halloween_admin = true},
    func = function(name, param)
        if param ~= "on" and param ~= "off" then
            return false, "Usage: /halloween_toggle on|off"
        end
        
        local state = (param == "on")
        halloween.set_enabled(state)
        
        return true, "Halloween mode " .. (state and "enabled" or "disabled") .. "."
    end,
})

-- Admin command: Allow a disguise
minetest.register_chatcommand("halloween_allow", {
    description = "Enable a specific disguise",
    params = "<id>",
    privs = {halloween_admin = true},
    func = function(name, param)
        if param == "" then
            return false, "Usage: /halloween_allow <id>"
        end
        
        if halloween.set_disguise_enabled(param, true) then
            return true, "Enabled disguise: " .. param
        else
            return false, "Disguise not found: " .. param
        end
    end,
})

-- Admin command: Block a disguise
minetest.register_chatcommand("halloween_block", {
    description = "Disable a specific disguise",
    params = "<id>",
    privs = {halloween_admin = true},
    func = function(name, param)
        if param == "" then
            return false, "Usage: /halloween_block <id>"
        end
        
        if halloween.set_disguise_enabled(param, false) then
            -- Clear any players currently using this disguise
            for _, player in ipairs(minetest.get_connected_players()) do
                if halloween.get_disguise(player) == param then
                    halloween.clear_disguise(player)
                end
            end
            return true, "Disabled disguise: " .. param
        else
            return false, "Disguise not found: " .. param
        end
    end,
})
