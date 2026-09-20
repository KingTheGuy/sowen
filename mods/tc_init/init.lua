local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

tc_init = {}

core.register_alias("mapgen_singlenode", "tc_nodes:stone")
core.register_alias("mapgen_stone", "tc_nodes:stone")
core.register_alias("mapgen_dirt", "tc_nodes:dirt")
core.register_alias("mapgen_water_source", "tc_nodes:water")
core.register_alias("mapgen_water_flowing", "tc_nodes:water_flowing")

dofile(mod_path.."/pickup_indicator.lua")

------
--- TRY TO SUCK ITEM ON FLOOR INTO PLAYER'S INV
------

-- tc_init.item_pull_radius = 2
-- local tick = 0
-- core.register_globalstep(function(dtime)
--   core.log("__builtin: "..dump(item_entity))
--   -- for key, value in pairs(core.registered_entities) do
--   --   if string.find(key,"__builtin") then
--   --     core.log("name: "..dump(key))
--   --   end
--   -- end
-- end)
--   tick = tick +1
--   if tick < 20 then
--     return
--   end
--   tick = 0
--   for _, player in ipairs(core.get_connected_players()) do
--     -- local main_inv = player:get_inventory():get_list("main")
--     -- core.log("inv: "..dump(main_inv))
--     for _, obj in ipairs(core.get_objects_inside_radius(player:get_pos(), tc_init.item_pull_radius)) do
--       local ent = obj:get_luaentity()
--       if ent ~= nil then
--         if ent.name == "__builtin:item" then
--           local p_pos = player:get_pos()
--           local o_pos = obj:get_pos()
--           if vector.distance(p_pos, o_pos) > 1 then
--             local new_pos = vector.new(p_pos.x,o_pos.y+1,p_pos.z)
--             obj:add_velocity(new_pos:subtract(o_pos):multiply(1.8))
--           end
--         end
--       end
--     end
--   end
-- end)
