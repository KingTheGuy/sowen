local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

local function create_item(name, def)
  -- def.tiles = def.tiles or { "blank.png" }
  def.inventory_image = def.inventory_image or "blank.png"
  core.register_craftitem(mod_name .. ":" .. name, def)
end

dofile(mod_path .. "/item_entity.lua")

create_item("plant_fiber", { inventory_image = mod_name .. "_plant_fiber.png" })

--TODO: create a cable attaching table use that

---@class
---@field obj
---@field pos1
---@field pos2
cable_attaching = {}

local function get_cable_attaching(p_ref)
  local p_name = p_ref:get_player_name()
  cable_attaching[p_name] = cable_attaching[p_name] or {}
  return cable_attaching[p_name]
end

create_item("rope", {
  inventory_image = mod_name .. "_rope.png",
  on_place = function(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    if pos == nil then
      return
    end
    -- core.log("pos: " .. pos:to_string())
    local meta = itemstack:get_meta()

    local p_attaching = get_cable_attaching(placer)

    local p_pos = placer:get_pos()
    --- lets get the first point
    if p_attaching.pos1 == nil then
      p_attaching.pos1 = pos
      local place_pos = pos:add(p_pos):divide(2)
      local added = core.add_entity(place_pos, "tc_entities:rope")
      if added == nil then
        -- core.log("nothing spawned")
        cable_attaching[placer:get_player_name()] = nil
      else
        -- core.log("adding!!!")
        --- lets make the second point be the player for the moment
        added:get_luaentity()._pos1 = p_attaching.pos1:to_string()
        added:get_luaentity()._pos2 = p_pos:to_string()
        -- core.log(pos1:to_string()..pos2:to_string())
        p_attaching.obj = added
        p_attaching.obj:get_luaentity()._placer = placer
        rope.update_visual(added:get_luaentity(), p_attaching.pos1, p_pos)
      end
    else
      p_attaching.obj:get_luaentity()._pos2 = pos:to_string()
      -- rope.update_visual(p_attaching.obj, p_attaching.pos1, pos)
      p_attaching.obj:get_luaentity()._placer = nil
      rope.update_visual(p_attaching.obj:get_luaentity(),p_attaching.pos1,pos)
      cable_attaching[placer:get_player_name()] = nil
      -- core.log("yes this is running!!!")
    end
    -- placer:set_wielded_item(itemstack, true)
  end,
})


create_item("rope_thick", {
  inventory_image = mod_name .. "_rope.png",
  on_place = function(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    if pos == nil then
      return
    end
    -- core.log("pos: " .. pos:to_string())
    local meta = itemstack:get_meta()

    local p_attaching = get_cable_attaching(placer)

    local p_pos = placer:get_pos()
    --- lets get the first point
    if p_attaching.pos1 == nil then
      p_attaching.pos1 = pos
      local place_pos = pos:add(p_pos):divide(2)
      local added = core.add_entity(place_pos, "tc_entities:rope_thick")
      if added == nil then
        -- core.log("nothing spawned")
        cable_attaching[placer:get_player_name()] = nil
      else
        -- core.log("adding!!!")
        --- lets make the second point be the player for the moment
        added:get_luaentity()._pos1 = p_attaching.pos1:to_string()
        added:get_luaentity()._pos2 = p_pos:to_string()
        -- core.log(pos1:to_string()..pos2:to_string())
        p_attaching.obj = added
        p_attaching.obj:get_luaentity()._placer = placer
        rope.update_visual(added:get_luaentity(), p_attaching.pos1, p_pos)
      end
    else
      p_attaching.obj:get_luaentity()._pos2 = pos:to_string()
      -- rope.update_visual(p_attaching.obj, p_attaching.pos1, pos)
      p_attaching.obj:get_luaentity()._placer = nil
      rope.update_visual(p_attaching.obj:get_luaentity(),p_attaching.pos1,pos)
      cable_attaching[placer:get_player_name()] = nil
      -- core.log("yes this is running!!!")
    end
    -- placer:set_wielded_item(itemstack, true)
  end,
})


create_item("chain", {
  inventory_image = mod_name .. "_rope.png",
  on_place = function(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    if pos == nil then
      return
    end
    -- core.log("pos: " .. pos:to_string())
    local meta = itemstack:get_meta()

    local p_attaching = get_cable_attaching(placer)

    local p_pos = placer:get_pos()
    --- lets get the first point
    if p_attaching.pos1 == nil then
      p_attaching.pos1 = pos
      local place_pos = pos:add(p_pos):divide(2)
      local added = core.add_entity(place_pos, "tc_entities:chain")
      if added == nil then
        -- core.log("nothing spawned")
        cable_attaching[placer:get_player_name()] = nil
      else
        -- core.log("adding!!!")
        --- lets make the second point be the player for the moment
        added:get_luaentity()._pos1 = p_attaching.pos1:to_string()
        added:get_luaentity()._pos2 = p_pos:to_string()
        -- core.log(pos1:to_string()..pos2:to_string())
        p_attaching.obj = added
        p_attaching.obj:get_luaentity()._placer = placer
        rope.update_visual(added:get_luaentity(), p_attaching.pos1, p_pos)
      end
    else
      p_attaching.obj:get_luaentity()._pos2 = pos:to_string()
      -- rope.update_visual(p_attaching.obj, p_attaching.pos1, pos)
      p_attaching.obj:get_luaentity()._placer = nil
      rope.update_visual(p_attaching.obj:get_luaentity(),p_attaching.pos1,pos)
      cable_attaching[placer:get_player_name()] = nil
      -- core.log("yes this is running!!!")
    end
    -- placer:set_wielded_item(itemstack, true)
  end,
})


create_item("bunting_flags", {
  inventory_image = mod_name .. "_rope.png",
  on_place = function(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    if pos == nil then
      return
    end
    -- core.log("pos: " .. pos:to_string())
    local meta = itemstack:get_meta()

    local p_attaching = get_cable_attaching(placer)

    local p_pos = placer:get_pos()
    --- lets get the first point
    if p_attaching.pos1 == nil then
      p_attaching.pos1 = pos
      local place_pos = pos:add(p_pos):divide(2)
      local added = core.add_entity(place_pos, "tc_entities:bunting_flags")
      if added == nil then
        -- core.log("nothing spawned")
        cable_attaching[placer:get_player_name()] = nil
      else
        -- core.log("adding!!!")
        --- lets make the second point be the player for the moment
        added:get_luaentity()._pos1 = p_attaching.pos1:to_string()
        added:get_luaentity()._pos2 = p_pos:to_string()
        -- core.log(pos1:to_string()..pos2:to_string())
        p_attaching.obj = added
        p_attaching.obj:get_luaentity()._placer = placer
        rope.update_visual(added:get_luaentity(), p_attaching.pos1, p_pos)
      end
    else
      p_attaching.obj:get_luaentity()._pos2 = pos:to_string()
      -- rope.update_visual(p_attaching.obj, p_attaching.pos1, pos)
      p_attaching.obj:get_luaentity()._placer = nil
      rope.update_visual(p_attaching.obj:get_luaentity(),p_attaching.pos1,pos)
      cable_attaching[placer:get_player_name()] = nil
      -- core.log("yes this is running!!!")
    end
    -- placer:set_wielded_item(itemstack, true)
  end,
})
