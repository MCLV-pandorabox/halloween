-- halloween/init.lua
-- Entry point for the Halloween disguise mod

-- Initialize global table
halloween = {}

-- Get mod path
halloween.modpath = minetest.get_modpath("halloween")

-- Initialize state
halloween.enabled = true
halloween.disguises = {}

-- Load submodules in order
dofile(halloween.modpath .. "/storage.lua")
dofile(halloween.modpath .. "/api.lua")
dofile(halloween.modpath .. "/registry.lua")
dofile(halloween.modpath .. "/effects.lua")
dofile(halloween.modpath .. "/commands.lua")

minetest.log("action", "[halloween] Mod loaded with " .. 
    #halloween.disguises .. " disguises available")
