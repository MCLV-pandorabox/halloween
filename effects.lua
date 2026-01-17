-- halloween/effects.lua
-- Special mob-specific abilities and effects

-- Initialize effects table
halloween.effects = {}

-- Example: Land Guard fireball shooting
halloween.effects["mobs_monster:land_guard"] = function(player, dtime)
    local ctrl = player:get_player_control()
    -- Fire on sneak + left-click
    if ctrl.sneak and ctrl.LMB then
        local meta = player:get_meta()
        local last_shot = meta:get_float("halloween_last_fireball") or 0
        local now = minetest.get_us_time() / 1000000
        
        -- Cooldown of 2 seconds
        if now - last_shot >= 2.0 then
            local pos = player:get_pos()
            local dir = player:get_look_dir()
            pos.y = pos.y + 1.5
            
            -- Try using mobs shooting API if available
            if mobs and mobs.shoot_projectile then
                mobs.shoot_projectile(player, pos, dir, "mobs_monster:fireball", 15)
            elseif minetest.registered_entities["mobs_monster:fireball"] then
                local obj = minetest.add_entity(pos, "mobs_monster:fireball")
                if obj then
                    obj:set_velocity({
                        x = dir.x * 15,
                        y = dir.y * 15,
                        z = dir.z * 15,
                    })
                end
            end
            
            meta:set_float("halloween_last_fireball", now)
        end
    end
end

-- Globalstep to apply active effects
minetest.register_globalstep(function(dtime)
    if not halloween.is_enabled() then return end
    
    for _, player in ipairs(minetest.get_connected_players()) do
        local disguise_id = halloween.get_disguise(player)
        if disguise_id and halloween.effects[disguise_id] then
            halloween.effects[disguise_id](player, dtime)
        end
    end
end)

-- Clean up player meta on leave
minetest.register_on_leaveplayer(function(player)
    halloween.clear_disguise(player)
end)
