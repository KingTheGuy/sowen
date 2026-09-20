local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

local function create_item(name, def)
  -- def.tiles = def.tiles or { "blank.png" }
  def.inventory_image = def.inventory_image or "blank.png"
  core.register_craftitem(mod_name .. ":" .. name, def)
end

dofile(mod_path .. "/item_entity.lua")

create_item("plant_fiber", { inventory_image = mod_name .. "_plant_fiber.png" })

create_item("rope", {
  inventory_image = mod_name .. "_rope.png",
  on_place = function(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    core.log("pos: " .. pos:to_string())
    local meta = itemstack:get_meta()
    if meta:get_string("pos1") == "" then
      meta:set_string("pos1", pos:to_string())
    else
      local pos1 = vector.from_string(meta:get_string("pos1"))
      if pos1 == "" or pos1 == nil then
        return
      end
      local pos2 = pos
      meta:set_string("pos1", "")
      -- meta:set_string("pos2",pos:to_string())
      core.log("both poses~" .. dump(pos1) .. dump(pos2))

      local place_pos = pos1:add(pos2):divide(2)
      core.log("placing at: " .. place_pos:to_string())
      local added = core.add_entity(place_pos, "tc_entities:rope")
      if added == nil then
        core.log("nothing spawned")
      else
        added:get_luaentity()._pos1 = pos1:to_string()
        added:get_luaentity()._pos2 = pos2:to_string()
        -- core.log(pos1:to_string()..pos2:to_string())
        rope.update_visual(added:get_luaentity(), pos1, pos2)
      end
    end
    placer:set_wielded_item(itemstack, true)
  end,
})
