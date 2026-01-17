-- halloween/api.lua
-- Core API for disguise system using overlay entities

-- Helper: check if Halloween is enabled
function halloween.is_enabled()
    return halloween.enabled
end

-- Helper: set Halloween enabled state
function halloween.set_enabled(state)
    halloween.save_enabled(state)
    if not state then
        halloween.clear_all_disguises()
    end
end

-- Register disguise overlay entity
minetest.register_entity("halloween:disguise_overlay", {
    initial_properties = {
        visual = "mesh",
        mesh = "character.b3d",
        textures = {"character.png"},
        visual_size = {x = 1, y = 1},
        collisionbox = {0, 0, 0, 0, 0, 0},
        physical = false,
        pointable = false,
        static_save = false,
    },

    _player_name = nil,
    _disguise_id = nil,
    _anim_data = nil,

    on_activate = function(self, staticdata, dtime_s)
        self.object:set_armor_groups({immortal = 1})
    end,

    on_step = function(self, dtime)
        if not self._player_name then return end
        local player = minetest.get_player_by_name(self._player_name)
        if not player then
            self.object:remove()
            return
        end

        -- Update animation based on player movement
        if self._anim_data then
            local ctrl = player:get_player_control()
            local vel = player:get_velocity() or {x=0, y=0, z=0}
            local speed2 = vel.x*vel.x + vel.z*vel.z

            local anim_start, anim_end, anim_speed

            if speed2 < 0.01 then
                -- standing
                anim_start = self._anim_data.stand_start or 0
                anim_end = self._anim_data.stand_end or 40
                anim_speed = self._anim_data.speed_normal or 15
            elseif ctrl.aux1 or ctrl.sneak then
                -- walking
                anim_start = self._anim_data.walk_start or 41
                anim_end = self._anim_data.walk_end or 80
                anim_speed = self._anim_data.speed_normal or 15
            else
                -- running
                anim_start = self._anim_data.run_start or self._anim_data.walk_start or 41
                anim_end = self._anim_data.run_end or self._anim_data.walk_end or 80
                anim_speed = self._anim_data.speed_run or self._anim_data.speed_normal or 30
            end

            self.object:set_animation(
                {x = anim_start, y = anim_end},
                anim_speed, 0
            )
        end
    end,
})

-- Set a player's disguise
function halloween.set_disguise(player, disguise_id)
    if not player or not disguise_id then return false end

    if not halloween.is_enabled() then
        return false, "Halloween mode is disabled"
    end

    local disguise = halloween.disguises[disguise_id]
    if not disguise then
        return false, "Disguise not found: " .. disguise_id
    end

    if not disguise.enabled then
        return false, "Disguise is disabled by admin"
    end

    -- Clear existing disguise first
    halloween.clear_disguise(player)

    -- Spawn overlay entity
    local pos = player:get_pos()
    if not pos then return false end

    local obj = minetest.add_entity(pos, "halloween:disguise_overlay")
    if not obj then return false, "Failed to create overlay" end

    -- Attach to player
    obj:set_attach(player, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
    
    -- Hide the player model (save original size first)
    local props = player:get_properties()
    local meta = player:get_meta()
    meta:set_string("halloween_original_visual_size", minetest.serialize(props.visual_size))
    player:set_properties({visual_size = {x=0, y=0}})

    -- Set visual properties
    obj:set_properties({
        mesh = disguise.mesh or "character.b3d",
        textures = type(disguise.textures) == "table" and disguise.textures or {disguise.textures or "character.png"},        visual_size = disguise.visual_size or {x=1, y=1},
    })

    -- Store entity data
    local ent = obj:get_luaentity()
    if ent then
        ent._player_name = player:get_player_name()
        ent._disguise_id = disguise_id
        ent._anim_data = disguise.animation
    end

    -- Store in player meta
    local meta = player:get_meta()
    meta:set_string("halloween_disguise", disguise_id)
    -- No need to store overlay ID - we'll find it by type when clearing
    return true
end

-- Clear a player's disguise
function halloween.clear_disguise(player)
    if not player then return end

    local meta = player:get_meta()
    -- Find and remove overlay entity by checking player name
    local pos = player:get_pos()
    if pos then
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "halloween:disguise_overlay" and 
               ent._player_name == player:get_player_name() then
                obj:remove()
                break
            end
        end
                meta:set_string("halloween_disguise", "")
                
        -- Restore player visibility
        local saved_size = meta:get_string("halloween_original_visual_size")
        if saved_size ~= "" then
            local visual_size = minetest.deserialize(saved_size)
            if visual_size then
                player:set_properties({visual_size = visual_size})
            end
            meta:set_string("halloween_original_visual_size", "")
        end
            end

end

-- Clear all disguises (when disabling globally)
function halloween.clear_all_disguises()
    for _, player in ipairs(minetest.get_connected_players()) do
        halloween.clear_disguise(player)
    end
end

-- Get current disguise ID for a player
function halloween.get_disguise(player)
    if not player then return nil end
    local meta = player:get_meta()
    local id = meta:get_string("halloween_disguise")
    return id ~= "" and id or nil
end

-- List all available disguises (optionally filtered)
function halloween.list_disguises(filter)
    local list = {}
    for id, def in pairs(halloween.disguises) do
        if def.enabled then
            if not filter or def.category == filter or id:find(filter) then
                table.insert(list, {id = id, category = def.category or "entity"})
            end
        end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

-- Register a custom disguise
function halloween.register_disguise(id, def)
    halloween.disguises[id] = {
        mesh = def.mesh,
        textures = def.textures,
        visual_size = def.visual_size or {x=1, y=1},
        animation = def.animation,
        category = def.category or "custom",
        enabled = def.enabled ~= false,
    }
end
