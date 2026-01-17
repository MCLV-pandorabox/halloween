-- halloween/registry.lua
-- Auto-discovery of mobs and entities for disguises

-- Build disguise list from Mobs Redo
if minetest.global_exists("mobs") and mobs.spawning_mobs then
    local count = 0
    for mob_name, _ in pairs(mobs.spawning_mobs) do
        -- Get the actual entity definition from core.registered_entities
        local ent_def = minetest.registered_entities[mob_name]
        if ent_def then
            halloween.register_disguise(mob_name, {
                mesh = ent_def.initial_properties and ent_def.initial_properties.mesh or ent_def.mesh,
                                    textures = (ent_def.initial_properties and ent_def.initial_properties.textures) or ent_def.textures,textures = ent_def.textures and ent_def.textures[1] or ent_def.textures,
                visual_size = (ent_def.initial_properties and ent_def.initial_properties.visual_size) or ent_def.visual_size,
                                    animation = ent_def.animation,animation = ent_def.animation,
                category = "mob",
                enabled = true,
            })
            count = count + 1
        end
    end
    minetest.log("action", "[halloween] Registered " .. count .. " mob disguises")
end

-- Build disguise list from all registered entities
-- (optionally filtered to avoid internal/helper entities)
local entity_blacklist = {
    ["__builtin:item"] = true,
    ["__builtin:falling_node"] = true,
    ["halloween:disguise_overlay"] = true,
}

local entity_count = 0
for ent_name, ent_def in pairs(minetest.registered_entities) do
    -- Skip blacklisted and already-registered mobs
    if not entity_blacklist[ent_name] and not halloween.disguises[ent_name] then
        if ent_def.mesh and ent_def.textures then
            halloween.register_disguise(ent_name, {
                mesh = ent_def.initial_properties and ent_def.initial_properties.mesh or ent_def.mesh, 
                                    textures = (ent_def.initial_properties and ent_def.initial_properties.textures) or ent_def.textures,textures = ent_def.textures[1] or ent_def.textures,
                visual_size = (ent_def.initial_properties and ent_def.initial_properties.visual_size) or ent_def.visual_size,                animation = ent_def.animation,
                category = "entity",
                enabled = false,  -- Disabled by default; admin must allow
            })
            entity_count = entity_count + 1
        end
    end
end

minetest.log("action", "[halloween] Registered " .. entity_count .. " additional entity disguises")
