local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

sw_nodes = {}

local defualt_node_groups = { oddly_breakable_by_hand = 3, choppy = 2, crumbly = 3, nodes = 1 }
local group_log = { oddly_breakable_by_hand = 3, logs = 1 }
local group_plank = { oddly_breakable_by_hand = 3, planks = 1 }
-- defualt_node_groups["dig_immediate"] = 3

--- SHAPES --- not sure if this will be used just yet
-- lcoal shapes = {
--   thin_log = {} -- thin logs also has connected stuff
-- }
-- sw_nodes.shapes = shapes

---FIXME: would be better to paint the node before placing (using param2 on placement)
---FIXME: if in 1st slot inv slot, sneaking and placing node will open the palette menu
---tries to paint node if paint_brush is in first inventory slot
---@param itemstack any
---@param placer any
---@param pointed_thing any
---@return any
local function paint_on_place(itemstack, placer, pointed_thing)
  -- core.item_place_node(itemstack, placer, pointed_thing)
  local item_first_slot = placer:get_inventory():get_stack("main", 1)
  if item_first_slot:get_name() == "sw_tools:paint_brush" then
    local brush_def = core.registered_items[item_first_slot:get_name()]
    local pointed = { above = pointed_thing.above, under = pointed_thing.above }
    brush_def.on_place(item_first_slot, placer, pointed)
  end
  -- local count = itemstack:get_count()
  -- itemstack:set_count(count - 1)
  -- return itemstack
end

local function _update_nodes(pos)
  local locs = {
    pos:add(vector.new(0, 1, 0)),
    pos:add(vector.new(0, -1, 0)),
    pos:add(vector.new(1, 0, 0)),
    pos:add(vector.new(-1, 0, 0)),
    pos:add(vector.new(0, 0, 1)),
    pos:add(vector.new(0, 0, -1))
  }
  for _, v_pos in ipairs(locs) do
    -- core.add_particle({
    --   size = 4,
    --   pos = v_pos,
    --   -- texture = "[fill:1x1:" .. "#fff",
    --   texture = "[fill:4x4:".."#439345",
    --   velocity = vector.new(0, 1, 0),
    --   expirationtime = 1,
    --   glow = 14,
    -- })
    local name = core.get_node(v_pos).name
    local node_def = core.registered_nodes[name]
    if node_def._update then node_def._update(v_pos) end
  end
end

--- drop item from node, will go direclty into player_inv player is close enough and there is space
---@param pos any
---@param node table
local function drop_item(pos, node, digger)
  local digger_pos = digger:get_pos():add(vector.new(0, 1.5, 0))
  local digger_distance = vector.distance(digger_pos, pos)
  local left_over
  if digger_distance < 2.3 then
    left_over = digger:get_inventory():add_item("main", ItemStack(node.name))
    -- core.log("left_over: " .. dump(left_over))
  end

  -- if there is left over, need to make sure it drops
  -- also if distance make sure it drops in work

  if left_over == nil or left_over:get_count() > 0 then
    local offset = 0.8 --- for some variation
    local new_pos = vector.new(
      math.random(pos.x, pos.x + offset),
      pos.y,
      math.random(pos.z, pos.z + offset)
    )
    local force = 1
    local acc = vector.new(
      math.random(-force, force),
      math.random(0, force),
      -- 0,
      math.random(-force, force)
    )
    local drop_node = node.name
    if left_over ~= nil and left_over:get_count() > 0 then
      drop_node = left_over:get_name()
    end
    local item_entity = core.add_item(pos, drop_node)
    item_entity:add_velocity(acc)
    item_entity:get_luaentity()._dropped = 1
  else
    sw_init.pickup_indicator(digger, node.name, 1)
    core.sound_play(sw_sounds.pickup().dug, { pos = digger_pos })
  end
  ---STACK same items:
  -- local within = core.get_objects_inside_radius(pos, 2.1)
  -- for index, obj in ipairs(within) do
  --   if obj == item_entity then
  --   else
  --     core.log("item data: "..dump(obj:get_luaentity()))
  --     if oldnode.name == string.split(obj:get_luaentity().itemstring," ")[1] then
  --       item_entity:move_to(obj:get_pos())
  --       return
  --     end
  --   end
  -- end
end

local function onDig(pos, node, digger, drops)
  -- core.log("in hand: " .. dump(digger:get_wielded_item()))
  local item = digger:get_wielded_item()
  local item_name = item:get_name()

  core.remove_node(pos)

  -- core.log("item: " .. dump(item))
  if core.registered_tools[item_name] and core.registered_tools[item_name].groups then
    local item_groups = core.registered_tools[item_name].groups
    if drops == nil then
      core.add_item(pos, node)
      core.log("no drops defined")
      return
    end
    for _, drop in ipairs(drops) do
      local all_groups = true
      --- check that tool has all the groups that the drop requires
      for drop_group, _ in pairs(drop.groups) do
        -- core.log("group: " .. dump(item_group))
        if item_groups[drop_group] ~= nil then
        else
          all_groups = false
        end
      end
      if all_groups == true then
        drop_item(pos, { name = drop.item }, digger)
        return true
      end
      -- drop.groups drop.item
    end
  end

  -- drop_item(pos, node)

  -- if core.registered_tools[item_name] and core.registered_tools[item_name].groups["knife"] then
  --   -- core.log("yes this is a knife")
  --   digger:get_inventory():add_item("main", ItemStack(node.name))
  -- else
  -- end

  return true
end

local function swap_varient(placer, pointed_thing)
  local p_dir = placer:get_look_dir():add(vector.new(0, 0, 0))
  local eye = placer:get_properties().eye_height
  local p_pos = placer:get_pos()
  p_pos.y = p_pos.y + eye -- take eye_height into account
  local new_pos = p_dir:multiply(4):add(p_pos)

  local ray = core.raycast(p_pos, new_pos, false, false):next()
  local dir = core.dir_to_facedir(p_dir)
  if ray then
    local point = ray.intersection_point
    if vector.new(pointed_thing.above.x, 0, pointed_thing.above.z) ~= vector.new(ray.under.x, 0, ray.under.z) then
      -- core.log("ray: "..dump(ray:next()))
      -- core.add_particle({
      --   size = 2,
      --   pos = point,
      --   texture = "[fill:1x1:" .. "#fff",
      --   velocity = vector.new(0, 0.8, 0),
      --   expirationtime = 1,
      --   glow = 14,
      -- })
      -- core.log("point: " .. dump(point))
      if point.y < pointed_thing.under.y then
        -- core.log("up")
        return false, dir
        -- if dir == 0 then
        --   dir = 8
        -- elseif dir == 1 then
        --   dir = 17
        -- elseif dir == 2 then
        --   dir = 6
        -- elseif dir == 3 then
        --   dir = 15
        -- end
        -- face = 22
      else
        -- core.log("down")
      end
      return true, dir
    elseif point.y < pointed_thing.under.y then
      return true, dir
    end
  end
  return false, dir
end

function sw_nodes.register_stairs(name, def)
  name = name .. "_stairs"
  for _, value in ipairs({ "_up", "_down" }) do
    local node_def = {}
    for key, kv in pairs(def) do
      if node_def[key] == "groups" then
      else
        node_def[key] = kv
      end
    end

    local groups = {}
    for g, gv in pairs(def.groups) do
      groups[g] = gv
    end
    node_def.groups = groups

    -- node_def.on_dig = nil
    node_def.drop = name .. "_up"
    node_def.drawtype = "nodebox"
    node_def.sunlight_propagates = true
    node_def.paramtype = "light"
    node_def.paramtype2 = "color4dir"
    node_def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"

    node_def.on_place = function(itemstack, placer, pointed_thing)
      local node = core.get_node(pointed_thing.above)
      local node_registered = core.registered_nodes[node.name]
      if not node_registered.buildable_to then
        return
      end
      -- core.log("drop? " .. dump(core.registered_nodes[itemstack:get_name()]))
      local swap, dir = swap_varient(placer, pointed_thing)
      if swap then
        core.set_node(pointed_thing.above, { name = name .. "_down", param2 = dir })
      else
        core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir })
      end
      paint_on_place(itemstack, placer, pointed_thing)
      local count = itemstack:get_count()
      itemstack:set_count(count - 1)
      return itemstack
    end

    local shape = {
      { 0.5,  0.0,  0.5,  -0.5, 0.5, 0.0 },
      { -0.5, -0.5, -0.5, 0.5,  0.0, 0.5 },
    }
    if value == "_down" then
      node_def.groups["not_in_creative_inventory"] = 1
      shape = {
        { 0.5,  -0.5, 0.5,  -0.5, 0.0, 0.0 },
        { -0.5, 0.0,  -0.5, 0.5,  0.5, 0.5 },
      }
    end
    node_def.node_box = {
      type = "fixed",
      fixed = shape
    }
    node_def.selection_box = {
      type = "fixed",
      fixed = shape
    }
    core.register_node(name .. value, node_def)
  end
end

function sw_nodes.register_step(name, def)
  name = name .. "_step"
  for _, value in ipairs({ "_up", "_down" }) do
    local node_def = {}
    for key, kv in pairs(def) do
      if node_def[key] == "groups" then
      else
        node_def[key] = kv
      end
    end

    local groups = {}
    for g, gv in pairs(def.groups) do
      groups[g] = gv
    end
    node_def.groups = groups

    -- node_def.on_dig = nil
    node_def.drop = name .. "_up"
    node_def.drawtype = "nodebox"
    node_def.sunlight_propagates = true
    node_def.paramtype = "light"
    node_def.paramtype2 = "color4dir"
    node_def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"

    node_def.on_place = function(itemstack, placer, pointed_thing)
      local node = core.get_node(pointed_thing.above)
      local node_registered = core.registered_nodes[node.name]
      if not node_registered.buildable_to then
        return
      end
      -- core.log("drop? " .. dump(core.registered_nodes[itemstack:get_name()]))
      local swap, dir = swap_varient(placer, pointed_thing)
      if swap then
        core.set_node(pointed_thing.above, { name = name .. "_down", param2 = dir })
      else
        core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir })
      end
      paint_on_place(itemstack, placer, pointed_thing)
      local count = itemstack:get_count()
      itemstack:set_count(count - 1)
      return itemstack
    end

    local shape = {
      { 0.5, -0.5, 0.5, -0.5, 0.0, 0.0 }
    }
    if value == "_down" then
      node_def.groups["not_in_creative_inventory"] = 1
      shape = {
        { 0.5, 0.0, 0.5, -0.5, 0.5, 0.0 }
      }
    end
    node_def.node_box = {
      type = "fixed",
      fixed = shape
    }
    node_def.selection_box = {
      type = "fixed",
      fixed = shape
    }
    core.register_node(name .. value, node_def)
  end
end

---registers base node, stairs, panel, steps
function sw_nodes.register_node_plus(name, def)
  -- base node
  -- stairs up/down
  -- panel
  -- steps up/down
  def.sounds = def.sounds or sw_sounds.wood()

  def.drop = mod_name .. ":" .. name
  def.drops = def.drops or nil
  def.on_dig = function(pos, node, digger)
    onDig(pos, node, digger, def.drops)
  end
  -- def.on_place = function(itemstack, placer, pointed_thing)
  def.after_place_node = function(pos, placer, itemstack, pointed_thing)
    --- NOTE: does not seem to like when previous node is buildable_to
    paint_on_place(itemstack, placer, pointed_thing)
    _update_nodes(pos)
  end
  def.after_destruct = function(pos, oldnode)
    _update_nodes(pos)
  end

  def.paramtype2 = "color"
  def.palette = sw_init.color_palette .. ""
  def.sounds = def.sounds or sw_sounds.stone()
  def.drawtype = def.drawtype or "normal" -- See "Node drawtypes"
  def.groups = def.groups or defualt_node_groups
  def.tiles = def.tiles or { mod_name .. "_stone.png" }
  def.is_ground_content = def.is_ground_content or true
  def.walkable = def.walkable or true                 -- If true, objects collide with node
  def.diggable = def.diggable or true                 -- If false, can never be dug
  def.buildable_to = def.buildable_to or false        -- If true, placed nodes can replace this node
  def.node_box = def.node_box or { type = "regular" } -- See "Node boxes"

  core.register_node(mod_name .. ":" .. name, def)
  sw_nodes.register_stairs(mod_name .. ":" .. name, def)
  sw_nodes.register_step(mod_name .. ":" .. name, def)
  sw_nodes.register_panel(mod_name .. ":" .. name, def)
  -- core.register_node(mod_name..":"..name.."_panel",def)
end

---comment
---@param name string
---@param def table
local function create_node(name, def)
  def.drops = def.drops or {}
  def.on_dig = function(pos, node, digger)
    onDig(pos, node, digger, def.drops)
  end
  def.after_place_node = function(pos, placer, itemstack, pointed_thing)
    --- NOTE: does not seem to like when previous node is buildable_to
    paint_on_place(itemstack, placer, pointed_thing)
  end
  def.after_destruct = function(pos, oldnode)
    _update_nodes(pos)
  end

  -- def.drawtype = def.drawtype or "normal" -- See "Node drawtypes"
  def.paramtype2 = def.paramtype2 or "color"
  def.palette = def.palette or sw_init.color_palette
  -- def.sounds = def.sounds or sw_sounds.stone()
  def.groups = def.groups or defualt_node_groups
  def.is_ground_content = def.is_ground_content or true
  def.diggable = def.diggable or true
  def.buildable_to = def.buildable_to or false
  -- def.node_box = def.node_box or { type = "regular" }
  -- def.collision_box = def.node_box or { type = "regular" }
  def.tiles = def.tiles or { mod_name .. "_stone.png" }

  core.register_node(mod_name .. ":" .. name, def)
end

local function create_flowing_node(name, def)
  core.register_node(mod_name .. ":" .. name, def)
end

local function create_light_source(name, def)
  core.register_node(mod_name .. ":" .. name, def)
end


local function create_grass_like(name, def)
  def.buildable_to = def.buildable_to or true
  def.drops = def.drops or {}
  def.on_dig = function(pos, node, digger)
    onDig(pos, node, digger, def.drops)
  end
  -- def.on_dig = function(pos, node, digger)
  --   core.log("in hand: " .. dump(digger:get_wielded_item()))
  --   local item = digger:get_wielded_item()
  --   local item_name = item:get_name()

  --   core.remove_node(pos)

  --   if core.registered_tools[item_name] and core.registered_tools[item_name].groups["rose"] then
  --     core.log("rose gold")
  --     drop_item(pos, { name = "sw_nodes:stone" })
  --   elseif core.registered_tools[item_name] and core.registered_tools[item_name].groups["knife"] then
  --     core.log("yes this is a knife")
  --     digger:get_inventory():add_item("main", ItemStack("sw_items:plant_fiber"))
  --   else
  --     drop_item(pos, node)
  --   end

  --   return true
  -- end
  def.sounds = sw_sounds.leaves()
  def.groups = defualt_node_groups
  def.drawtype = "plantlike"
  def.paramtype = "light"
  -- def.paramtype2 = "4dir"
  def.paramtype2 = "meshoptions"
  def.waving = 1
  def.floodable = false
  def.node_box = {
    type = "fixed",
    fixed = { -0.2, -0.5, -0.2, 0.2, -0.1, 0.2 }
  }
  def.selection_box = {
    type = "fixed",
    fixed = { -0.2, -0.5, -0.2, 0.2, -0.1, 0.2 }
  }
  def.sunlight_propagates = true
  def.walkable = false
  def.place_param2 = 8

  -- def.after_place_node = function(pos, placer, itemstack, pointed_thing)
  --   local node = core.get_node(pos)
  --   node.param2 = 8
  --   core.set_node(pos,node)
  --   core.log("yup")
  -- end


  -- def.drop = {
  --   max_items = 1,
  --   items = {
  --     {
  --       -- Only drop if using an item in the "magicwand" group, or
  --       -- an item that is in both the "pickaxe" and the "lucky"
  --       -- groups.
  --       tool_groups = {
  --         "knife",
  --         -- "magicwand",
  --         -- { "pickaxe", "lucky" }
  --       },
  --       items = { "sw_items:plant_fiber" },
  --     },
  --     {
  --       items = { "" },
  --     },
  --     {
  --       items = { mod_name .. ":" .. name },
  --     },
  --   },
  -- }
  core.register_node(mod_name .. ":" .. name, def)
end

local function create_planks(name, def)
  def.sounds = sw_sounds.wood()
  def.paramtype2 = "color"
  def.palette = sw_init.color_palette .. ""
  local log_size = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }
  def.drawtype = "node"
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
  -- def.paramtype2 = "wallmounted"
  def.groups = group_plank
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or {
    -- mod_name .. "_oak_planks.png",
    { name = mod_name .. "_oak_planks.png", align_style = "world", scale = 3 },

    -- mod_name .. "_oak_log_top.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
  }

  --- THE LOG
  core.register_node(mod_name .. ":" .. name, def)
  return def
end

local function rot_placer(placer, pointed_thing)
  local p_dir = placer:get_look_dir():add(vector.new(0, 0, 0))
  local eye = placer:get_properties().eye_height
  local p_pos = placer:get_pos()
  p_pos.y = p_pos.y + eye -- take eye_height into account
  local new_pos = p_dir:multiply(4):add(p_pos)

  local ray = core.raycast(p_pos, new_pos, false, false):next()
  local dir = core.dir_to_facedir(p_dir)
  if ray then
    if vector.new(pointed_thing.above.x, 0, pointed_thing.above.z) ~= vector.new(ray.under.x, 0, ray.under.z) then
      -- core.log("ray: "..dump(ray:next()))
      local point = ray.intersection_point
      -- core.add_particle({
      --   size = 2,
      --   pos = point,
      --   texture = "[fill:1x1:" .. "#fff",
      --   velocity = vector.new(0, 0.8, 0),
      --   expirationtime = 1,
      --   glow = 14,
      -- })
      -- core.log("point: " .. dump(point))
      if point.y > pointed_thing.under.y then
        if dir == 0 then
          dir = 8
        elseif dir == 1 then
          dir = 17
        elseif dir == 2 then
          dir = 6
        elseif dir == 3 then
          dir = 15
        end
        -- face = 22
        -- core.log("up")
      else
        -- core.log("down")
      end
    end
  end
  return dir
end


local function create_planks_step_up(name, def)
  def.sounds = sw_sounds.wood()
  local log_size = { 0.5, -0.5, 0.5, -0.5, 0.0, 0.0 }
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.paramtype2 = "colorfacedir"
  -- def.palette = sw_init.color_palette.."^[sheet:32x1:0,0"
  def.paramtype2 = "color4dir"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
  -- def.paramtype2 = "wallmounted"
  def.groups = group_plank
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or {
    -- mod_name .. "_oak_planks.png",
    { name = mod_name .. "_oak_planks.png", align_style = "world", scale = 3 },
    -- mod_name .. "_oak_log_top.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
  }
  def.on_place = function(itemstack, placer, pointed_thing)
    local node = core.get_node(pointed_thing.above)
    local node_def = core.registered_nodes[node.name]
    if not node_def.buildable_to then
      return
    end
    local swap, dir = swap_varient(placer, pointed_thing)
    if swap then
      core.set_node(pointed_thing.above, { name = mod_name .. ":" .. name .. "_down", param2 = dir })
    else
      core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir })
    end
    -- core.log("dir: "..dump(p_dir))
    -- core.log("yup")
    local count = itemstack:get_count()
    itemstack:set_count(count - 1)
    return itemstack
  end

  --- THE LOG
  core.register_node(mod_name .. ":" .. name .. "_up", def)
end


local function create_planks_step_down(name, def)
  def.sounds = sw_sounds.wood()
  local log_size = { 0.5, 0.0, 0.5, -0.5, 0.5, 0.0 }
  def.drop = mod_name .. ":" .. name .. "_up"
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.paramtype2 = "colorfacedir"
  -- def.palette = sw_init.color_palette.."^[sheet:32x1:0,0"
  def.paramtype2 = "color4dir"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
  -- def.paramtype2 = "wallmounted"
  def.groups = group_plank
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or {
    -- mod_name .. "_oak_planks.png",
    { name = mod_name .. "_oak_planks.png", align_style = "world", scale = 3 },
    -- mod_name .. "_oak_log_top.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
  }
  -- def.on_place = function(itemstack, placer, pointed_thing)
  --   local node = core.get_node(pointed_thing.above)
  --   local node_def = core.registered_nodes[node.name]
  --   if not node_def.buildable_to then
  --     return
  --   end
  --   local dir = rot_placer(placer, pointed_thing)
  --   -- core.log("dir: "..dump(p_dir))
  --   -- core.log("yup")
  --   core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir })
  --   local count = itemstack:get_count()
  --   itemstack:set_count(count - 1)
  --   return itemstack
  -- end

  --- THE LOG
  core.register_node(mod_name .. ":" .. name .. "_down", def)
end


local function create_planks_stairs_up(name, def)
  def.sounds = sw_sounds.wood()
  local log_size = {
    { 0.5,  0.0,  0.5,  -0.5, 0.5, 0.0 },
    { -0.5, -0.5, -0.5, 0.5,  0.0, 0.5 },
  }
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  def.paramtype2 = "color4dir"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
  -- def.paramtype2 = "wallmounted"
  def.groups = group_plank
  def.tiles = def.tiles or {
    -- mod_name .. "_oak_planks.png",
    { name = mod_name .. "_oak_planks.png", align_style = "world", scale = 3 },
    -- mod_name .. "_oak_log_top.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
  }
  def.on_place = function(itemstack, placer, pointed_thing)
    -- local node = core.get_node(pointed_thing.above)
    -- local node_def = core.registered_nodes[node.name]
    -- if not node_def.buildable_to then
    --   return
    -- end
    -- local dir = rot_placer(placer, pointed_thing)
    -- -- core.log("dir: "..dump(p_dir))
    -- -- core.log("yup")
    -- core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir })
    local swap, dir = swap_varient(placer, pointed_thing)
    if swap then
      core.set_node(pointed_thing.above, { name = mod_name .. ":" .. name .. "_down", param2 = dir })
    else
      core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir })
    end
    local count = itemstack:get_count()
    itemstack:set_count(count - 1)
    return itemstack
  end

  core.register_node(mod_name .. ":" .. name .. "_up", def)
end


local function create_planks_stairs_down(name, def)
  def.sounds = sw_sounds.wood()
  local log_size = {
    { 0.5,  -0.5, 0.5,  -0.5, 0.0, 0.0 },
    { -0.5, 0.0,  -0.5, 0.5,  0.5, 0.5 },
  }

  def.drop = mod_name .. ":" .. name .. "_up"
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  def.paramtype2 = "color4dir"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
  -- def.paramtype2 = "wallmounted"
  def.groups = group_plank
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or {
    -- mod_name .. "_oak_planks.png",
    { name = mod_name .. "_oak_planks.png", align_style = "world", scale = 3 },
  }

  -- core.register_node(mod_name .. ":" .. name, def)
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
  core.register_node(mod_name .. ":" .. name .. "_down", def)
end

function sw_nodes.register_panel(name, def)
  name = name .. "_panel"
  local node_def = {}
  for key, kv in pairs(def) do
    node_def[key] = kv
  end
  node_def.sounds = sw_sounds.wood()
  local shape = { -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 }
  -- node_def.paramtype2 = "4dir"
  node_def.sunlight_propagates = true
  node_def.paramtype = "light"
  -- node_def.place_param2 = "8"
  node_def.paramtype2 = "colorwallmounted"
  node_def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  node_def.drawtype = "nodebox"
  node_def.node_box = {
    type = "fixed",
    fixed = shape
  }
  node_def.selection_box = {
    type = "fixed",
    fixed = shape
  }
  -- node_def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  --- THE LOG
  core.register_node(name, node_def)
end

local function create_log(name, def)
  def.sounds = sw_sounds.wood()
  local log_size = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }
  def.drawtype = "node"
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
  -- def.paramtype2 = "wallmounted"
  def.paramtype2 = "colorwallmounted"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.groups = group_log
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or {
    mod_name .. "_oak_log_top.png",
    mod_name .. "_oak_log_top.png",
    mod_name .. "_oak_log_sides.png",
    mod_name .. "_oak_log_sides.png",
    mod_name .. "_oak_log_sides.png",
    mod_name .. "_oak_log_sides.png",
  }

  --- THE LOG
  core.register_node(mod_name .. ":" .. name, def)
end

local function create_log_thin(name, def)
  def.sounds = sw_sounds.wood()
  -- def.sunlight_propagates = false
  -- def.paramtype = "light"
  -- def.paramtype2 = "wallmounted"
  def.paramtype2 = "colorwallmounted"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.groups = group_log
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or {
    -- mod_name .. "_oak_log_top.png",
    -- mod_name .. "_oak_log_top.png",
    mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
  }
  --- THE BRANCH
  local branch_box = {
    type = "connected",
    fixed = { -0.4, -0.4, -0.4, 0.4, 0.4, 0.4 },
    connect_top = { -0.4, -0.4, -0.4, 0.4, 0.5, 0.4 },
    connect_bottom = { -0.4, -0.5, -0.4, 0.4, 0.4, 0.4 },
    connect_left = { -0.5, -0.4, -0.4, 0.4, 0.4, 0.4 },
    connect_right = { -0.4, -0.4, -0.4, 0.5, 0.4, 0.4 },
    connect_front = { -0.4, -0.4, -0.5, 0.4, 0.4, 0.4 },
    connect_back = { -0.4, -0.4, -0.4, 0.4, 0.4, 0.5 },
    -- disconnected = { -0.3, -0.5, -0.3, 0.3, 0.5, 0.3 }, -- when there is *no* neighbor
  }
  -- def.connects_to = {"sw_nodes:oak_log","sw_nodes:oak_log_thin","sw_nodes:oak_log_branch","group:soil","group:"}
  def.connects_to = { "group:logs", "group:soil" }
  def.drawtype = "nodebox"
  def.selection_box = branch_box
  def.node_box = branch_box
  core.register_node(mod_name .. ":" .. name .. "_thin", def)
end

local function create_log_branch(name, def)
  def.sounds = sw_sounds.wood()
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.paramtype2 = "wallmounted"
  def.paramtype2 = "colorwallmounted"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.groups = group_log
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or {
    -- mod_name .. "_oak_log_top.png",
    -- mod_name .. "_oak_log_top.png",
    mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
    -- mod_name .. "_oak_log_sides.png",
  }
  --- THE BRANCH
  local branch_box = {
    type = "connected",
    fixed = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
    connect_top = { -0.2, -0.2, -0.2, 0.2, 0.5, 0.2 },
    connect_bottom = { -0.2, -0.5, -0.2, 0.2, 0.2, 0.2 },
    connect_left = { -0.5, -0.2, -0.2, 0.2, 0.2, 0.2 },
    connect_right = { -0.2, -0.2, -0.2, 0.5, 0.2, 0.2 },
    connect_front = { -0.2, -0.2, -0.5, 0.2, 0.2, 0.2 },
    connect_back = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.5 },
    -- disconnected = { -0.3, -0.5, -0.3, 0.3, 0.5, 0.3 }, -- when there is *no* neighbor
  }
  def.drawtype = "nodebox"
  def.selection_box = branch_box
  def.node_box = branch_box
  def.connects_to = { "group:logs", "group:soil", "group:wallmounted" }

  core.register_node(mod_name .. ":" .. name .. "_branch", def)
end

---FIXME: only have function as a chopping if it is point ip
local function create_chopping_log(name, def)
  def.sounds = sw_sounds.wood()
  def.sunlight_propagates = true
  def.paramtype = "light"
  def.drawtype = "nodebox"
  -- def.paramtype2 = "wallmounted"
  def.paramtype2 = "colorwallmounted"
  def.palette = sw_init.color_palette .. "^[sheet:8x1:0,0"
  def.node_box = {
    type = "fixed",
    fixed = { -0.4, -0.5, -0.4, 0.4, 0.1, 0.4 }
  }
  def.groups = group_log
  -- def.node_box = {
  --   type="fixed",
  --   fixed = { -0.3, -0.5, -0.3, 0.3, -0.4, 0.3 }
  -- }
  def.tiles = def.tiles or { mod_name .. "_oak_log_top.png", mod_name .. "_oak_log_sides.png" }
  core.register_node(mod_name .. ":" .. name, def)
end

create_grass_like("tall_grass", {
  tiles = { mod_name .. "_tall_grass.png" },
  groups = { oddly_breakable_by_hand = 1, nodes = 1 },
  drops = {
    -- {groups = {rose=1},item = "sw_nodes:dirt"},
    { groups = { knife = 1 }, item = "sw_items:plant_fiber" },
  },
  buildable_to = true,
  _update = function(pos)
    local is_air = core.get_node(pos:add(vector.new(0, -1, 0)))
    if is_air.name == "air" or is_air.name == "" then
      core.remove_node(pos)
    end
  end
})

create_grass_like("oak_sapling", {
  tiles = { mod_name .. "_oak_sapling.png" },
  groups = { oddly_breakable_by_hand = 1, nodes = 1 },
  drops = {
    -- {groups = {rose=1},item = "sw_nodes:dirt"},
    -- { groups = { knife = 1 }, item = "sw_items:plant_fiber" },
    { groups = { knife = 1 }, item = "sw_items:plant_fiber" },
  },
  on_place = function(itemstack, placer, pointed_thing)
    local node_under = core.get_node(pointed_thing.under)
    local node_under_def = core.registered_nodes[node_under.name]
    local pos = pointed_thing.above
    if node_under_def.buildable_to then
      pos = pointed_thing.under
    end
    -- core.set_node(pos, { name = itemstack:get_name()})
    core.remove_node(pos)
    core.place_schematic(
      pos,
      mod_path .. "/../sw_mapgen/schematics/tree" .. math.random(1, 3) .. ".mts",
      math.random(0, 3) * 90,
      {},
      false,
      "place_center_x, place_center_z"
    )
    local count = itemstack:get_count()
    itemstack:set_count(count - 1)
    return itemstack
  end,
})

-- local torch_nodebox = {
--     type = "wallmounted",
--     wall_top = { -0.1, -0.5, -0.1, 0.1, 0.1, 0.1 },
--     wall_bottom = { -0.1, -0.1, -0.1, 0.1, 0.5, 0.1 },
--     wall_side = { -0.1, -0.5, -0.4, 0.4, 0.1, 0.1 }
-- }

local function flame_particle(position)
  return {
    -- vec3
    pos = position:add(vector.new(0, 0.5, 0)),
    -- all particles will appear at this exact position throughout the lifetime
    -- of the particlespawner
    amount = 1,

    time = 0,

    texture = {
      name = "sw_nodes_fire_particle.png",
      -- the texture specification string

      alpha = 1.0,
      -- controls how visible the particle is; at 1.0 the particle is fully
      -- visible, at 0, it is completely invisible.

      alpha_tween = { 1, 0 },
      -- can be used instead of `alpha` to animate the alpha value over the
      -- particle's lifetime. these tween tables work identically to the tween
      -- tables used in particlespawner properties, except that time references
      -- are understood with respect to the particle's lifetime, not the
      -- spawner's. {1,0} fades the particle out over its lifetime.

      scale = { x = 8, y = 8 },
      -- scales the texture onscreen

      -- scale_tween = {
      --   { x = 1, y = 1 },
      --   { x = 0, y = 1 },
      -- },
      -- animates the scale over the particle's lifetime. works like the
      -- alpha_tween table, but can accept two-dimensional vectors as well as
      -- integer values. the example value would cause the particle to shrink
      -- in one dimension over the course of its life until it disappears

      blend = "alpha",
      -- (default) blends transparent pixels with those they are drawn atop
      -- according to the alpha channel of the source texture. useful for
      -- e.g. material objects like rocks, dirt, smoke, or node chunks
      -- note: there will be rendering bugs when particles interact with
      -- translucent nodes. particles are also not transparency-sorted
      -- relative to each other.
      animation = {
        type = "vertical_frames",

        aspect_w = 16,
        -- Width of a frame in pixels
        -- Integer in range [1, 65535]

        aspect_h = 16,
        -- Height of a frame in pixels
        -- Integer in range [1, 65535]

        length = 0.3,
        -- Full loop length
      },
      -- overrides the particlespawner's global animation property for a single
      -- specific texture
    },

  }
end

create_light_source("torch", {
  drawtype = "mesh",
  mesh = "sw_nodes_torch.glb",
  visual_scale = 10,
  wield_scale = { x = 16, y = 16, z = 16 },
  paramtype = "light",
  light_source = 9,
  paramtype2 = "4dir",
  use_texture_alpha = "blend",
  tiles = {
    {
      name = "sw_nodes_torch_animated-sheet.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 32,
        -- Width of a frame in pixels
        -- Integer in range [1, 65535]
        aspect_h = 32,
        -- Height of a frame in pixels
        -- Integer in range [1, 65535]
        length = 0.6,
        -- Full loop length
      }
    },
  },
  diggable = true,
  groups = { oddly_breakable_by_hand = 3, wallmounted = 1 },
  sunlight_propagates = true,
  walkable = false,
  node_box = {
    type = "fixed",
    fixed = { -0.1, -0.5, -0.1, 0.1, 0.1, 0.1 }
  },
  selection_box = {
    type = "fixed",
    fixed = { -0.1, -0.5, -0.1, 0.1, 0.1, 0.1 }
  },
  -- on_construct = function(pos)
  -- end,

  -- switch to wall node if need
  after_place_node = function(pos, placer, itemstack, pointed_thing)
    if pointed_thing.under.y == pos.y then
      core.log("ok this should be all mounted")
      core.log("param2: " .. dump(core.get_node(pos).param2))
      core.set_node(pos, { name = itemstack:get_name() .. "_wall", param2 = core.get_node(pos).param2 })
    else
      core.log("grounded")
    end
    -- core.add_particlespawner(flame_particle(pos))
  end,

  on_destruct = function(pos)
    -- core.delete_particlespawner(id)
  end,



  -- on_timer = function(pos, elapsed, node, timeout)
  --   core.log("yes!")
  --   local timer = core.get_node_timer(pos)
  --   timer:start(1)
  -- end,
  -- on_construct = function(pos)
  --   local timer = core.get_node_timer(pos)
  --   timer:start(1)
  -- end,
})

create_light_source("torch_wall", {
  drop = mod_name .. ":" .. "torch",
  drawtype = "mesh",
  mesh = "sw_nodes_torch_wall.glb",
  visual_scale = 10,
  wield_scale = { x = 16, y = 16, z = 16 },
  paramtype = "light",
  light_source = 9,
  paramtype2 = "4dir",
  use_texture_alpha = "blend",
  tiles = {
    {
      name = "sw_nodes_torch_animated-sheet.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 32,
        -- Width of a frame in pixels
        -- Integer in range [1, 65535]
        aspect_h = 32,
        -- Height of a frame in pixels
        -- Integer in range [1, 65535]
        length = 0.6,
        -- Full loop length
      }
    },
  },
  diggable = true,
  groups = { oddly_breakable_by_hand = 3, wallmounted = 1, not_in_creative_inventory =1 },
  sunlight_propagates = true,
  walkable = false,
  node_box = {
    type = "fixed",
    fixed = { -0.1, -0.5, -0.1, 0.1, 0.1, 0.1 }
  },
  selection_box = {
    type = "fixed",
    fixed = { -0.1, -0.5, -0.1, 0.1, 0.1, 0.1 }
  },
  -- on_timer = function(pos, elapsed, node, timeout)
  --   core.log("yes!")
  --   local timer = core.get_node_timer(pos)
  --   timer:start(1)
  -- end,
  -- on_construct = function(pos)
  --   local timer = core.get_node_timer(pos)
  --   timer:start(1)
  -- end,
})

create_flowing_node("water", {
  drawtype = "liquid",
  paramtype = "light",
  tiles = { mod_name .. "_water.png" .. "^[opacity:160" },
  post_effect_color = "#1c408e" .. "90",
  post_effect_color_shaded = true,
  use_texture_alpha = "blend",
  liquid_renewable = true,
  liquid_viscosity = 0,
  move_resistance = 0,
  walkable = false, -- If true, objects collide with node
  drowning = 1,
  waving = 3,
  liquidtype = "source", -- specifies liquid flowing physics
  liquid_alternative_flowing = mod_name .. ":water_flowing",
  liquid_alternative_source = mod_name .. ":water",
  sunlight_propagates = false,
  diggable = false,    -- If false, can never be dug
  pointable = false,
  buildable_to = true, -- If true, placed nodes can replace this node
  liquid_range = 0,
})

create_flowing_node("water_flowing", {
  drawtype = "flowingliquid",
  paramtype2 = "flowingliquid",
  paramtype = "light",
  liquidtype = "flowing", -- specifies liquid flowing physics
  tiles = { mod_name .. "_water.png" .. "^[opacity:120" },
  special_tiles = { mod_name .. "_water.png" .. "^[opacity:120", mod_name .. "_water.png" .. "^[opacity:120" },
  groups = { not_in_creative_inventory = 1},
  use_texture_alpha = "blend",
  liquid_renewable = false,
  liquid_viscosity = 0,
  walkable = false, -- If true, objects collide with node
  drowning = 1,
  waving = 3,
  liquid_alternative_flowing = mod_name .. ":water_flowing",
  liquid_alternative_source = mod_name .. ":water",
  sunlight_propagates = true,
  diggable = false,    -- If false, can never be dug
  pointable = false,
  buildable_to = true, -- If true, placed nodes can replace this node
  liquid_range = 4,
})

create_chopping_log("oak_chopping_log", {})
create_log("oak_log", {})
create_log_thin("oak_log", {})
create_log_branch("oak_log", {})
-- local plank_def = create_planks("oak_planks", {})
-- create_planks_step_up("oak_planks_step", {})
-- create_planks_step_down("oak_planks_step", {})
-- create_planks_stairs_up("oak_planks_stairs", {})
-- create_planks_stairs_down("oak_planks_stairs", {})
-- sw_nodes.register_panel(mod_name..":".."oak_planks", plank_def)

sw_nodes.register_node_plus("oak_planks", {
  tiles = { { name = mod_name .. "_oak_planks.png", align_style = "world", scale = 3 } },
  drops = {
    { groups = { pickaxe = 1 }, item = "sw_nodes:oak_planks" },
  },
  groups = { pickaxe = 2 }
})

create_node("grass_mesh", {
  drawtype = "mesh",
  mesh = "sw_nodes_grass.glb",
  visual_scale = 10,
  -- visual_scale = {x=10,y=10,z=10},
  tiles = { mod_name .. "_grass.png" },
  use_texture_alpha = "blend",
})

create_node("oak_leaves", {
  drawtype = "mesh",
  mesh = "sw_nodes_oak_leaves_mesh.glb",
  visual_scale = 14,
  tiles = { mod_name .. "_oak_leaves_mesh.png" },
  use_texture_alpha = "blend",
  palette = sw_init.color_palette .. "^[sheet:8x1:0,0",
  -- palette = "apollo-1x.png" .. "^[sheet:8x1:0,0",
  sunlight_propagates = true,
  paramtype = "light",
  paramtype2 = "color4dir",
  waving = 2,
  climbable = true,
  walkable = false,
  move_resistance = 1,
  selection_box = {
    type = "fixed",
    fixed = { -0.4, -0.4, -0.4, 0.4, 0.4, 0.4 }
  },
  sounds = sw_sounds.leaves(),
  drops = {
    { groups = { oddly_breakable_by_hand = 1 }, item = "sw_nodes:oak_sapling" },
    { groups = { rose = 1 },                    item = "sw_nodes:oak_leaves" },
    { groups = { knife = 1 },                   item = "sw_nodes:oak_sapling" },
  },

})

sw_nodes.register_node_plus("concrete", {
  tiles = { mod_name .. "_concrete.png" },
  drops = {
    { groups = { pickaxe = 1 }, item = "sw_nodes:concrete" },
  },
  groups = { pickaxe = 1 },
  sounds = sw_sounds.stone()
})

sw_nodes.register_node_plus("cave_ground", {
  tiles = { mod_name .. "_cave_ground_2.png" },
  drops = {
    { groups = { pickaxe = 1 }, item = "sw_nodes:cave_ground" },
  },
  groups = { pickaxe = 2 },
  sounds = sw_sounds.stone()
})

sw_nodes.register_node_plus("grass", {
  -- tiles = { mod_name.."_grass_top.png" },
  tiles = { { name = mod_name .. "_grass_top.png", align_style = "world", scale = 3 } },
  drops = {
    { groups = { pickaxe = 1 }, item = "sw_nodes:dirt" },
  },
  groups = { pickaxe = 3, soil = 1 },
  sounds = sw_sounds.grass(),

  on_construct = function(pos)
    core.get_node_timer(pos):start(math.random(2))
  end,

  _update = function(pos)
    local node = core.get_node(pos)
    local node_def = core.registered_nodes[node.name]
    core.get_node_timer(pos):start(math.random(2))
  end,

  on_timer = function(pos, elapsed, node, timeout)
    -- core.log("timer!")
    -- core.add_particle({
    --   size = 4,
    --   pos = pos:add(vector.new(0, 1, 0)),
    --   -- texture = "[fill:1x1:" .. "#fff",
    --   texture = "[fill:4x4:#fff",
    --   -- velocity = vector.new(0, 1, 0),
    --   expirationtime = 1,
    --   glow = 14,
    -- })
    --- TRY SPREAD, convert dirt to grass
    if math.random(8) == 8 then
      --- check self
      local node_above = core.get_node(pos:add(vector.new(0, 1, 0)))
      local node_def = core.registered_nodes[node_above.name]
      -- step,panel,stairs.. should use a group
      if node_above.name ~= "air" or node_above.name ~= "" then
        if string.find(node_above.name, "_panel") == nil then
          if string.find(node_above.name, "_step") == nil then
            if string.find(node_above.name, "_stairs") == nil then
              if node_def.buildable_to == false then
                -- stay grass
                -- core.log("converting to dirt!!!")
                core.set_node(pos, { name = mod_name .. ":dirt" })
                return false
              end
            end
          end
        end
      end
      local locs = {
        -- pos:add(vector.new(0,1,0)),
        -- pos:add(vector.new(0,-1,0)),
        pos:add(vector.new(1, 0, 0)),
        pos:add(vector.new(-1, 0, 0)),
        pos:add(vector.new(0, 0, 1)),
        pos:add(vector.new(0, 0, -1))
      }
      --- check surrounding
      for _, v_pos in ipairs(locs) do
        local name = core.get_node(v_pos).name
        -- local node_def = core.registered_nodes[name]
        if name == mod_name .. ":dirt" then
          local on_dirt = core.get_node(v_pos:add(vector.new(0, 1, 0))) -- node above the new possible grass
          local on_dirt_def = core.registered_nodes[on_dirt.name]
          -- step,panel,stairs.. should use a group
          if on_dirt.name == "air" or on_dirt.name == "" or on_dirt_def.buildable_to == true or string.find(on_dirt.name, "_panel") or string.find(on_dirt.name, "_step") or string.find(on_dirt.name, "_stairs") then
            -- core.log("node next to me is dirt, lets set it to grass")
            core.set_node(v_pos, node)
          end
        end
        -- if node_def._update then node_def._update(v_pos) end
      end
      return false
    end
    return true
  end,
})

sw_nodes.register_node_plus("dirt", {
  tiles = { mod_name .. "_dirt.png" },
  drops = {
    { groups = { pickaxe = 1 }, item = "sw_nodes:dirt" },
  },
  groups = { pickaxe = 3, soil = 1 },
  sounds = sw_sounds.dirt(),
  -- tell other nodes around it to attempt to update (tell grass to spread over)
  _update = function(pos)
    local locs = {
      pos:add(vector.new(1, 0, 0)),
      pos:add(vector.new(-1, 0, 0)),
      pos:add(vector.new(0, 0, 1)),
      pos:add(vector.new(0, 0, -1))
    }
    for _, v_pos in ipairs(locs) do
      local name = core.get_node(v_pos).name
      if name ~= "sw_nodes:dirt" then
        local node_def = core.registered_nodes[name]
        if node_def._update then node_def._update(v_pos) end
      end
    end
  end,
})

sw_nodes.register_node_plus("cobblestone", {
  tiles = { { name = mod_name .. "_cobblestone.png", align_style = "world", scale = 3 } },
  drops = {
    { groups = { pickaxe = 1 }, item = "sw_nodes:cobblestone" },
  },
  groups = { pickaxe = 2, nodes = 1 },
  sounds = sw_sounds.stone()
})

sw_nodes.register_node_plus("stone", {
  tiles = { mod_name .. "_stone.png" },
  drops = {
    { groups = { pickaxe = 1, rose = 1 }, item = "sw_nodes:stone" },
    { groups = { pickaxe = 1 },           item = "sw_nodes:cobblestone" },
  },
  groups = { pickaxe = 1, nodes = 1 },
  sounds = sw_sounds.stone()
})

sw_nodes.register_node_plus("stone_bricks", {
  tiles = { { name = mod_name .. "_stone_bricks.png", align_style = "world", scale = 3 } },
  drops = {
    { groups = { pickaxe = 1 }, item = "sw_nodes:stone_bricks" },
  },
  groups = { pickaxe = 1, nodes = 1 },
  sounds = sw_sounds.stone()
})
---TODO:
-- log,log_thin -> stripped, stairs, step, fence
-- planks -> stairs, step, fence
-- FENCE, MAY BE MESHES
-- !!!! planks should use a texture overlay.
