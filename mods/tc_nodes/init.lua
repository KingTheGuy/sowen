local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

local defualt_node_groups = { oddly_breakable_by_hand = 3, choppy = 2, crumbly = 3, nodes = 1 }
local group_log = { oddly_breakable_by_hand = 3, logs = 1 }
local group_plank = { oddly_breakable_by_hand = 3, planks = 1 }
-- defualt_node_groups["dig_immediate"] = 3

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
    tc_init.pickup_indicator(digger, node.name, 1)
    core.sound_play(tc_sounds.pickup().dug, { pos = digger_pos })
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

---comment
---@param name string
---@param def table
local function create_node(name, def)
  def.drops = def.drops or {}
  def.on_dig = function(pos, node, digger)
    onDig(pos, node, digger, def.drops)
  end

  -- def.after_dig_node = function(pos, oldnode, oldmetadata, digger)
  --   return nil
  -- end

  -- def.after_destruct = function(pos, oldnode)
  --   drop_item(pos,oldnode)
  -- end
  -- def.drop = ""

  def.paramtype2 = "color"
  def.palette = tc_init.color_palette..""
  def.sounds = def.sounds or tc_sounds.stone()
  def.drawtype = def.drawtype or "normal" -- See "Node drawtypes"
  def.groups = def.groups or defualt_node_groups
  def.tiles = def.tiles or { mod_name .. "_stone.png" }
  def.is_ground_content = def.is_ground_content or true
  def.walkable = def.walkable or true                 -- If true, objects collide with node
  def.diggable = def.diggable or true                 -- If false, can never be dug
  def.buildable_to = def.buildable_to or false        -- If true, placed nodes can replace this node
  def.node_box = def.node_box or { type = "regular" } -- See "Node boxes"

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
  --     drop_item(pos, { name = "tc_nodes:stone" })
  --   elseif core.registered_tools[item_name] and core.registered_tools[item_name].groups["knife"] then
  --     core.log("yes this is a knife")
  --     digger:get_inventory():add_item("main", ItemStack("tc_items:plant_fiber"))
  --   else
  --     drop_item(pos, node)
  --   end

  --   return true
  -- end
  def.sounds = tc_sounds.plant()
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
  --       items = { "tc_items:plant_fiber" },
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
  def.sounds = tc_sounds.plank()
  def.paramtype2 = "color"
  def.palette = tc_init.color_palette..""
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


local function swap_varient(placer, pointed_thing)
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
      if point.y < pointed_thing.under.y then
        core.log("up")
        return false,dir
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
        core.log("down")
      end
      return true,dir
    end
  end
  return false,dir
end

local function create_planks_step_up(name, def)
  def.sounds = tc_sounds.plank()
  local log_size = { 0.5, -0.5, 0.5, -0.5, 0.0, 0.0 }
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.paramtype2 = "colorfacedir"
  -- def.palette = tc_init.color_palette.."^[sheet:32x1:0,0"
  def.paramtype2 = "color4dir"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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
    local swap,dir = swap_varient(placer, pointed_thing)
    if swap then
      core.set_node(pointed_thing.above, { name = mod_name..":"..name.."_down", param2 = dir})
    else
      core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir})
    end
    -- core.log("dir: "..dump(p_dir))
    -- core.log("yup")
    local count = itemstack:get_count()
    itemstack:set_count(count - 1)
    return itemstack
  end

  --- THE LOG
  core.register_node(mod_name .. ":" .. name.."_up", def)
end


local function create_planks_step_down(name, def)
  def.sounds = tc_sounds.plank()
  local log_size = { 0.5, 0.0, 0.5, -0.5, 0.5, 0.0 }
  def.drop = mod_name..":"..name.."_up"
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.paramtype2 = "colorfacedir"
  -- def.palette = tc_init.color_palette.."^[sheet:32x1:0,0"
  def.paramtype2 = "color4dir"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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
  core.register_node(mod_name .. ":" .. name.."_down", def)
end


local function create_planks_stairs_up(name, def)
  def.sounds = tc_sounds.plank()
  local log_size = {
    { 0.5,  0.0,  0.5,  -0.5, 0.5, 0.0 },
    { -0.5, -0.5, -0.5, 0.5,  0.0, 0.5 },
  }
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  def.paramtype2 = "color4dir"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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
    local swap,dir = swap_varient(placer, pointed_thing)
    if swap then
      core.set_node(pointed_thing.above, { name = mod_name..":"..name.."_down", param2 = dir})
    else
      core.set_node(pointed_thing.above, { name = itemstack:get_name(), param2 = dir})
    end
    local count = itemstack:get_count()
    itemstack:set_count(count - 1)
    return itemstack
  end

  core.register_node(mod_name .. ":" .. name.."_up", def)
end


local function create_planks_stairs_down(name, def)
  def.sounds = tc_sounds.plank()
  local log_size = {
    { 0.5,  -0.5,  0.5,  -0.5, 0.0, 0.0 },
    { -0.5, 0.0, -0.5, 0.5,  0.5, 0.5 },
  }

  def.drop = mod_name..":"..name.."_up"
  def.drawtype = "nodebox"
  def.sunlight_propagates = true
  def.paramtype = "light"
  def.paramtype2 = "color4dir"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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
  core.register_node(mod_name .. ":" .. name.."_down", def)
end

local function create_planks_panel(name, def)
  def.sounds = tc_sounds.plank()
  local log_size = { -0.5, -0.5, -0.5, 0.5, 0.0, 0.5 }
  -- def.paramtype2 = "4dir"
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.place_param2 = "8"
  def.paramtype2 = "colorwallmounted"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
  def.drawtype = "nodebox"
  def.node_box = {
    type = "fixed",
    fixed = log_size
  }
  def.selection_box = {
    type = "fixed",
    fixed = log_size
  }
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
end

local function create_log(name, def)
  def.sounds = tc_sounds.plank()
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
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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
  def.sounds = tc_sounds.plank()
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.paramtype2 = "wallmounted"
  def.paramtype2 = "colorwallmounted"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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
  -- def.connects_to = {"tc_nodes:oak_log","tc_nodes:oak_log_thin","tc_nodes:oak_log_branch","group:soil","group:"}
  def.connects_to = { "group:logs", "group:soil" }
  def.drawtype = "nodebox"
  def.selection_box = branch_box
  def.node_box = branch_box
  core.register_node(mod_name .. ":" .. name .. "_thin", def)
end

local function create_log_branch(name, def)
  def.sounds = tc_sounds.plank()
  def.sunlight_propagates = true
  def.paramtype = "light"
  -- def.paramtype2 = "wallmounted"
  def.paramtype2 = "colorwallmounted"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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
  def.connects_to = { "group:logs", "group:soil","group:wallmounted"}

  core.register_node(mod_name .. ":" .. name .. "_branch", def)
end

---FIXME: only have function as a chopping if it is point ip
local function create_chopping_log(name, def)
  def.sounds = tc_sounds.plank()
  def.sunlight_propagates = true
  def.paramtype = "light"
  def.drawtype = "nodebox"
  -- def.paramtype2 = "wallmounted"
  def.paramtype2 = "colorwallmounted"
  def.palette = tc_init.color_palette.."^[sheet:8x1:0,0"
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

create_node("stone", {
  -- tiles = { { name = mod_name .. "_stone.png", align_style = "world", scale = 3 } },
  tiles = { mod_name .. "_stone.png" },
  groups = { pickaxe = 1, nodes = 1 },
  drops = {
    { groups = { pickaxe = 1, rose = 1 }, item = "tc_nodes:stone" },
    { groups = { pickaxe = 1 },           item = "tc_nodes:cobblestone" },
  }
})

create_node("cobblestone", {
  tiles = { { name = mod_name .. "_cobblestone.png", align_style = "world", scale = 3 } },
  -- groups = { pickaxe = 1 },
  groups = { pickaxe = 1, nodes = 1 },
  drops = {
    { groups = { pickaxe = 1 }, item = "tc_nodes:cobblestone" },
  }
})

create_node("dirt", {
  tiles = { mod_name .. "_dirt.png" },
  sounds = tc_sounds.dirt(),
  groups = { pickaxe = 3, soil = 3, nodes = 1 },
  drops = {
    { groups = { pickaxe = 1 }, item = "tc_nodes:dirt" },
  }
})

create_node("stone_bricks", {
  tiles = { { name = mod_name .. "_stone_bricks.png", align_style = "world", scale = 3 } },
  groups = { pickaxe = 1, nodes = 1 },
  drops = {
    { groups = { pickaxe = 1 }, item = "tc_nodes:stone_bricks" },
  }
})

create_grass_like("tall_grass", {
  tiles = { mod_name .. "_tall_grass.png" },
  groups = { oddly_breakable_by_hand = 1, nodes = 1 },
  drops = {
    -- {groups = {rose=1},item = "tc_nodes:dirt"},
    { groups = { knife = 1 }, item = "tc_items:plant_fiber" },
  }
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
      name = "tc_nodes_fire_particle.png",
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
  mesh = "tc_nodes_torch.glb",
  visual_scale = 10,
  wield_scale = { x = 16, y = 16, z = 16 },
  paramtype = "light",
  light_source = 9,
  paramtype2 = "4dir",
  use_texture_alpha = "blend",
  tiles = {
    {
      name = "tc_nodes_torch_animated-sheet.png",
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
  mesh = "tc_nodes_torch_wall.glb",
  visual_scale = 10,
  wield_scale = { x = 16, y = 16, z = 16 },
  paramtype = "light",
  light_source = 9,
  paramtype2 = "4dir",
  use_texture_alpha = "blend",
  tiles = {
    {
      name = "tc_nodes_torch_animated-sheet.png",
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
create_planks("oak_planks", {})
create_planks_step_up("oak_planks_step", {})
create_planks_step_down("oak_planks_step", {})
create_planks_stairs_up("oak_planks_stairs", {})
create_planks_stairs_down("oak_planks_stairs", {})
create_planks_panel("oak_planks_panel", {})
---TODO:
-- log,log_thin -> stripped, stairs, step, fence
-- planks -> stairs, step, fence
-- FENCE, MAY BE MESHES
-- !!!! planks should use a texture overlay.
