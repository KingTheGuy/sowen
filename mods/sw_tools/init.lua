local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

sw_tools = {}

dofile(mod_path .. "/../sw_form/init.lua")

local function create_tool(name, def)
  -- def.tiles = def.tiles or { "blank.png" }
  def.inventory_image = def.inventory_image or "blank.png"
  core.register_tool(mod_name .. ":" .. name, def)
end

core.override_item("", {
  tool_capabilities = {
    full_punch_interval = 0.1,
    groupcaps = {
      oddly_breakable_by_hand = {
        -- max_drop_level = 7,
        times = { 0, 0, 0.1, 7, 12, 30, 300 },
        uses = 0,
      },
    },
    -- groups = {hand=1},
    damage_groups = hand_damage_groups,
  },
})


create_tool("knife_flint", {
  range = 2.5,
  groups = { knife = 1 },
  inventory_image = mod_name .. "_knife_flint.png",
})

create_tool("knife_rose_gold", {
  range = 2.5,
  groups = { knife = 1, rose = 1 },
  inventory_image = mod_name .. "_knife_rose_gold.png",
})


create_tool("pickaxe_flint", {
  range = 3,
  groups = { pickaxe = 1 },
  tool_capabilities = {
    groupcaps = {
      pickaxe = { maxlevel = 3, uses = 20, times = { [1] = 1.80, [2] = 1.40, [3] = 1.20 } }
    },
  },
  inventory_image = mod_name .. "_pickaxe_flint.png",
})

create_tool("pickaxe_rose_gold", {
  range = 3,
  groups = { pickaxe = 1, rose = 1 },
  tool_capabilities = {
    groupcaps = {
      pickaxe = { maxlevel = 3, uses = 20, times = { [1] = 1.00, [2] = 1.00, [3] = 0.40 } }
    },
  },
  inventory_image = mod_name .. "_pickaxe_rose_gold.png",
})


--- NOTE: issues with the chisel, is that it can potencially be used to break into things..
-- a "FIX" could be to make things PROTECTED to prevent this
create_tool("chisel_and_hammer", {
  range = 4,
  groups = {},
  -- tool_capabilities = {
  --   groupcaps = {
  --     pickaxe = { maxlevel = 3, uses = 20, times = { [1] = 1.00, [2] = 1.00, [3] = 0.40 } }
  --   },
  -- },
  inventory_image = "(sw_tools_chisel.png^sw_tools_hammer.png)",
  wield_image = mod_name .. "_chisel.png",

  on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.under ~= nil then
      local node = core.get_node(pointed_thing.under)
      core.log("point: " .. dump(pointed_thing))
      core.log("param2:" .. node.param2)
    end
    -- core.log("dir: "..dump(core.facedir_to_dir(node.param2)))
  end,

  --- THIS SHOULD BE USING GROUPS OF SOME SORT AND NOT DOING THINGS VIA NAMES
  on_place = function(itemstack, placer, pointed_thing)
    local node = core.get_node(pointed_thing.under)
    local p_dir = placer:get_look_dir()
    local wall_dir = core.dir_to_wallmounted(p_dir)

    -- core.log("dir: "..dump(p_dir))
    -- core.log("wall dir: "..dump(wall_dir))

    core.sound_play(sw_sounds.stone().dug, { pos = pointed_thing.under })

    if string.find(node.name, "_panel") then
      core.set_node(pointed_thing.under, { name = "sw_nodes:oak_planks", param2 = node.param })
    else
      core.set_node(pointed_thing.under, { name = "sw_nodes:oak_planks_panel", param2 = (11 * 8) + wall_dir })
    end
  end,
})


local colors = ""

local padding = 0.5
colors = colors .. sw_form.button({ 0 + padding, 0 + padding }, { 1, 1 }, "wash off", "paint_color:" .. 0,
  "sw_tools_paint_droplet.png")
local row = 0
local col = 1
for i = 1, 31, 1 do
  colors = colors ..
      sw_form.button({ col + padding, row + padding }, { 1, 1 }, "wash off", "paint_color:" .. i,
        string.format(sw_init.color_palette .. "^[sheet:256x1:%s,0", i))
  col = col + 1
  if col == 9 then
    row = row + 1
    col = 0
  end
end
local paint_palette_form = table.concat({
  "formspec_version[10]",
  "size[10,8]",
  sw_form.container({ 0, 0 }, { 10, 8 }, "#453451", {
    colors,
  }),
})
---END FORM STUFF---

create_tool("paint_brush", {
  description = [[
[sneak+right_click]: open palette;
[right_click]: paint block;
[left_click]: sample color;
Put in hotbar 1 to place and color blocks.
    ]],
  range = 5,
  groups = {},
  -- tool_capabilities = {
  --   groupcaps = {
  --     pickaxe = { maxlevel = 3, uses = 20, times = { [1] = 1.00, [2] = 1.00, [3] = 0.40 } }
  --   },
  -- },
  inventory_image = mod_name .. "_paint_brush.png",
  -- inventory_image = "(sw_tools_chisel.png^sw_tools_hammer.png)",
  -- wield_image = mod_name .."_chisel.png",

  update_paint_brush = function(player, item, color)
    item:get_meta():set_int("_color", color)
    local brush_overlay = mod_name ..
    "_paint_brush.png^(" ..
    string.format(sw_init.color_palette .. "^[sheet:256x1:%s,0", color) .. "^[mask:sw_tools_paint_brush_overlay.png)"
    item:get_meta():set_string("inventory_image", brush_overlay)
    item:get_meta():set_string("wield_image", brush_overlay)
    player:set_wielded_item(item, true)
  end,

  on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.under == nil then
      return
    end
    -- if user:get_player_control().sneak == false then
    --   return
    -- end
    local node = core.get_node(pointed_thing.under)
    -- core.log("point: " .. dump(pointed_thing))
    -- core.log("param2:" .. node.param2)
    -- core.log("lets get the color")
    -- core.log("dir: "..dump(core.facedir_to_dir(node.param2)))
    local color = 0
    local node_def = core.registered_nodes[node.name]
    -- core.log("paramtype2: " .. node_def.paramtype2)
    local pt2 = node_def.paramtype2
    if pt2 == "color" then
      color = node.param2
    elseif pt2 == "colorfacedir" then
      color = math.floor(node.param2 / 32)
    elseif pt2 == "color4dir" then
      color = math.floor(node.param2 / 8)
    elseif pt2 == "colorwallmounted" then
      color = math.floor(node.param2 / 8)
    else
    end
    -- core.log("color: " .. color)
    core.sound_play(sw_sounds.pickup().dug, { pos = pointed_thing.above, pitch = 3.8 })

    local eye = user:get_properties().eye_height
    local p_pos = user:get_pos()
    p_pos.y = p_pos.y + eye -- take eye_height into account

    local splat_pos = pointed_thing.above:add(pointed_thing.under):divide(2)
    local vel = p_pos:subtract(splat_pos):divide(2)

    local texture = string.format(sw_init.color_palette .. "^[sheet:256x1:%s,0", color) ..
        "^[mask:sw_items_item_particle.png"
    core.add_particle({
      size = 8,
      pos = splat_pos,
      velocity = vel,
      expirationtime = 0.25,
      glow = 0,
      -- texture = "[fill:1x1:" .. "#fff",
      -- texture = "sw_items_item_particle.png^[colorize:"..string.format(sw_init.color_palette.."^[sheet:32x32:%s,0",p_index),
      -- texture = string.format(sw_init.color_palette.."^[sheet:32x32:%s,0",p_index).."^[mask:sw_items_item_particle.png",
      texture = texture,
      -- texture = "sw_tools_paint_ani.png",
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
    })
    -- update_paint_brush(user,itemstack,color)
    local paint_brush_def = core.registered_tools[itemstack:get_name()]
    paint_brush_def.update_paint_brush(user, itemstack, color)
    core.close_formspec(user:get_player_name(), "paint_palette_form")
  end,

  --- THIS SHOULD BE USING GROUPS OF SOME SORT AND NOT DOING THINGS VIA NAMES
  on_place = function(itemstack, placer, pointed_thing)
    local p_name = placer:get_player_name()
    if placer:get_player_control().sneak == true then
      -- core.log("ok lets open the palette")
      core.show_formspec(p_name, "paint_palette_form", paint_palette_form)
      return
    end
    -- core.log("now we apply the color")
    local node = core.get_node(pointed_thing.under)
    local meta = itemstack:get_meta()
    local p_index = 1
    -- core.log("_color: "..meta:get_int("_color"))
    if meta:get_string("_color") ~= "" then
      p_index = meta:get_int("_color")
      -- core.log("found color")
    end
    local color = 0
    local node_def = core.registered_nodes[node.name]
    -- core.log("paramtype2: " .. node_def.paramtype2)
    local pt2 = node_def.paramtype2
    if pt2 == "color" then
      -- core.log("color!!")
      color = p_index
    elseif pt2 == "colorfacedir" then
      color = (p_index * 32) + (node.param2 % 32)
    elseif pt2 == "color4dir" then
      color = (p_index * 8) + (node.param2 % 8)
    elseif pt2 == "colorwallmounted" then
      local wallmounted = node.param2 % 8
      color = (p_index * 8) + wallmounted
    else
      -- core.log("this can't be colored")
      return
    end
    node.param2 = color
    -- core.log("parma %: "..dump(p_index))
    -- node.param2 = node.param2 % 8

    local eye = placer:get_properties().eye_height
    local p_pos = placer:get_pos()
    p_pos.y = p_pos.y + eye -- take eye_height into account

    local splat_pos = pointed_thing.above:add(pointed_thing.under):divide(2)
    local vel = p_pos:subtract(splat_pos):divide(2)
    -- core.log("splat pos: "..dump(splat_pos))
    local texture = string.format(sw_init.color_palette .. "^[sheet:256x1:%s,0", p_index) ..
        "^[mask:sw_tools_paint_ani.png"
    local particle = {
      size = 8,
      pos = splat_pos,
      velocity = vel,
      expirationtime = 0.25,
      glow = 0,
      -- texture = "[fill:1x1:" .. "#fff",
      -- texture = "sw_items_item_particle.png^[colorize:"..string.format(sw_init.color_palette.."^[sheet:32x32:%s,0",p_index),
      -- texture = string.format(sw_init.color_palette.."^[sheet:32x32:%s,0",p_index).."^[mask:sw_items_item_particle.png",
      texture = texture,
      -- texture = "sw_tools_paint_ani.png",
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
    }
    for i = 1, 2, 1 do
      if i == 2 then
        core.after(0.25, function()
          core.sound_play(sw_sounds.pickup().dug, { pos = pointed_thing.under, pitch = 1.5, gain = 0.1 })
          texture = texture .. "^[transform4"
          particle.texture = texture
          core.add_particle(particle)
          -- core.add_particle({
          --   size = 8,
          --   pos = splat_pos,
          --   velocity = vel,
          --   expirationtime = 0.25,
          --   glow = 0,
          --   -- texture = "[fill:1x1:" .. "#fff",
          --   -- texture = "sw_items_item_particle.png^[colorize:"..string.format(sw_init.color_palette.."^[sheet:32x32:%s,0",p_index),
          --   -- texture = string.format(sw_init.color_palette.."^[sheet:32x32:%s,0",p_index).."^[mask:sw_items_item_particle.png",
          --   texture = texture,
          --   -- texture = "sw_tools_paint_ani.png",
          --   animation = {
          --     type = "vertical_frames",

          --     aspect_w = 16,
          --     -- Width of a frame in pixels
          --     -- Integer in range [1, 65535]

          --     aspect_h = 16,
          --     -- Height of a frame in pixels
          --     -- Integer in range [1, 65535]

          --     length = 0.3,
          --     -- Full loop length
          --   },
          -- })
        end)
      else
        core.sound_play(sw_sounds.pickup().dug, { pos = splat_pos, pitch = 1.5, gain = 0.1 })
        core.add_particle(particle)
      end
    end

    core.swap_node(pointed_thing.under, node)

    -- local p_dir = placer:get_look_dir()
    -- local wall_dir = core.dir_to_wallmounted(p_dir)

    -- -- core.log("dir: "..dump(p_dir))
    -- -- core.log("wall dir: "..dump(wall_dir))

    -- core.sound_play(sw_sounds.stone().dug, { pos = pointed_thing.under})

    -- if string.find(node.name,"_panel") then
    --   core.set_node(pointed_thing.under,{name="sw_nodes:oak_planks",param2=node.param})
    -- else
    --   core.set_node(pointed_thing.under,{name="sw_nodes:oak_planks_panel",param2=(11*8)+wall_dir})
    -- end
  end,
  on_secondary_use = function(itemstack, user, pointed_thing)
    local p_name = user:get_player_name()
    if user:get_player_control().sneak == true then
      -- core.log("ok lets open the palette")
      core.show_formspec(p_name, "paint_palette_form", paint_palette_form)
      return
    end
    -- core.log("pointed: " .. dump(pointed_thing))
    if pointed_thing.type == "object" then
      local entity = pointed_thing.ref:get_luaentity()
      if entity._paintable == "true" then
        local wield_meta = itemstack:get_meta()
        local color_index = 0
        if wield_meta:get_string("_color") ~= "" then
          color_index = wield_meta:get_int("_color")
        end
        -- core.log(dump(entity._pos1))
        -- entity._color1 = string.format(sw_init.color_palette.."^[sheet:256x1:%s,0", color_index)

        if entity._t_flip == 1 then
          entity._t_flip = 0
          entity._color1 = color_index
        else
          entity._t_flip = 1
          entity._color2 = color_index
        end

        local pos1 = vector.from_string(entity._pos1)
        local pos2 = vector.from_string(entity._pos2)
        rope.update_visual(entity, pos1, pos2)
        -- string.format(sw_init.color_palette.."^[sheet:256x1:%s,0", color) .. "^[mask:sw_tools_paint_brush_overlay.png)")
      end
    end
  end,

})

core.register_chatcommand("pc", {
  description = "set paint brush color",
  func = function(name, param)
    local p_ref = core.get_player_by_name(name)
    local wield = p_ref:get_wielded_item()
    if wield:get_name() == mod_name .. ":paint_brush" then
      core.log("found it")
      if param == "" then
        core.log("specifiy color index")
        return
      end
      core.log("color index: " .. param)
      wield:get_meta():set_int("_color", param)
      core.log("did it set? " .. wield:get_meta():get_int("_color"))
      wield:get_meta():set_string("inventory_image",
        mod_name ..
        "_paint_brush.png^(" ..
        string.format(sw_init.color_palette .. "^[sheet:256x1:%s,0", param) .. "^[mask:sw_tools_paint_brush_overlay.png)")
      p_ref:set_wielded_item(wield, true)
    else
      core.log("not holding paint brush")
      return
    end
  end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
  if formname == "paint_palette_form" then
    -- core.log("field: " .. dump(fields))
    -- local p_ref = core.get_player_by_name(player)
    local wield = player:get_wielded_item()
    for key, value in pairs(fields) do
      if string.find(key, "paint_color") then
        local color = string.split(key, ":")[2]
        local paint_brush_def = core.registered_tools[wield:get_name()]
        paint_brush_def.update_paint_brush(player, wield, color)
        core.close_formspec(player:get_player_name(), "paint_palette_form")
      end
    end
  end
end)
