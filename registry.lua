-- halloween/registry.lua
-- Auto-discovery of mobs and entities for disguises

-- Build disguise list from Mobs Redo
if minetest.global_exists("mobs") and mobs.registered_mobs then
    for mob_name, mob_def in pairs(mobs.registered_mobs) do
        halloween.register_disguise(mob_name, {
            mesh = mob_def.mesh,
            textures = mob_def.textures and mob_def.textures[1] or mob_def.textures,
            visual_size = mob_def.visual_size,
            animation = mob_def.animation,
            category = "mob",
            enabled = true,
        })
    end
    minetest.log("action", "[halloween] Registered " .. 
        table.getn(mobs.registered_mobs) .. " mob disguises")
end

-- Build disguise list from all registered entities
-- (optionally filtered to avoid internal/helper entities)
local entity_blacklist = {
    ["__builtin:item"] = true,
    ["__builtin:falling_node"] = true,
    ["halloween:disguise_overlay"] = true,
}

local entity_count = 0
for entity_name, entity_def in pairs(minetest.registered_entities) do
    -- Skip blacklisted and already-registered mobs
    if not entity_blacklist[entity_name] and not halloween.disguises[entity_name] then
        -- Only register if it has visual properties
        if entity_def.mesh or entity_def.visual == "mesh" then
            halloween.register_disguise(entity_name, {
                mesh = entity_def.mesh or "character.b3d",
                textures = entity_def.textures or {"character.png"},
                visual_size = entity_def.visual_size or {x=1, y=1},
                animation = entity_def.animation,
                category = "entity",
                enabled = true,
            })
            entity_count = entity_count + 1
        end
    end
end

minetest.log("action", "[halloween] Registered " .. entity_count .. " entity disguises")

-- Load persisted enable/disable flags from storage
halloween.load_disguise_flags()
