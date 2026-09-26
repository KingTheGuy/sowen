local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

tc_init = {}

-- tc_init.color_palette = "hept32.png"
-- tc_init.color_palette = "nanner-pancakes-1x.png"
tc_init.color_palette = "apollo-1x.png"

core.register_alias("mapgen_singlenode", "tc_nodes:stone")
core.register_alias("mapgen_stone", "tc_nodes:stone")
core.register_alias("mapgen_dirt", "tc_nodes:dirt")
core.register_alias("mapgen_dirt_with_grass", "tc_nodes:grass")
core.register_alias("mapgen_water_source", "tc_nodes:water")
core.register_alias("mapgen_water_flowing", "tc_nodes:water_flowing")

dofile(mod_path .. "/pickup_indicator.lua")
dofile(mod_path .. "/../tc_form/init.lua")

tc_form.register_listener()
core.register_on_joinplayer(function(player_ref, last_login)
  tc_form.defualt_inv(player_ref)
  player_ref:set_lighting({
    shadows = { intensity = 0.33 },
    volumetric_light = { strength = 0.45 },
    exposure = {
      luminance_min = -3.5,
      luminance_max = -2.5,
      exposure_correction = 0.35,
      speed_dark_bright = 1500,
      speed_bright_dark = 700,
    },
    bloom = {
      intensity = 0.02, -- 0.0 - 1.0
      strength_factor = 0.5, -- 0.1 - 10.0
      radius = 0.5,  -- 0.1 - 8.0
    },
    -- saturation = 0.8,
  })
end)

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
