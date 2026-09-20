local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

core.override_item("", {
  groups = { oddly_breakable_by_hand = 3, choppy = 2 ,crumbly = 3}
})


-- on_place = function(itemstack, placer, pointed_thing)
--   core.log("defuq")
-- end,

core.register_on_joinplayer(function(player_ref, last_login)
  -- player_ref:set_camera({mode = "third_front"})
--   core.log("player joined")
--   local ent = core.add_entity(ObjectRef:get_pos(), "core_player:hair_scrubby")
--   ent:set_attach(ObjectRef, "Head",{x=0,y=-1.35,z=0},{x=0,y=180,z=0})
--   -- ent:set_attach(ObjectRef, "Head",{x=0,y=-1.35,z=0},ObjectRef:get_rotation())
--   ent:set_properties({visual_size = {x = 1, y = 1, z = 1}})
--   if core.get_modpath("core_player") and core_player then
--     ObjectRef:set_properties({visual = "mesh",mesh=core_player.model,textures=core_player.textures,visual_size = {x=10,y=10,z=10}})
--   end

end)
