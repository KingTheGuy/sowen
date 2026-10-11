local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

sw_form = {}

dofile(mod_path .. "/../sw_sounds/init.lua")

---FORM STUFF (should move)
function sw_form.container(pos, size, bg_color, content)
  return table.concat({
    string.format("container[%s,%s]", pos[1], pos[2]),
    string.format("box[%s,%s;%s,%s;%s]", 0, 0, size[1], size[2], bg_color),
    table.concat(content),
    "container_end[]",
  })
  -- return string.format("container[%s,%s]%scontainer_end[]", pos[1], pos[2], table.concat(content))
end

function sw_form.button(pos, size, name, label, image)
  return table.concat({
    string.format("tooltip[%s,%s;%s,%s;%s]", pos[1], pos[2], size[1], size[2], name),
    string.format("image_button[%s,%s;%s,%s;%s;%s;;true;false]", pos[1], pos[2], size[1], size[2], image, label)
  })
end

sw_form.hotbar_size = 11
sw_form.player_inv_col = 5
-- sw_form.inv_hotbar_padding = 0.5

local slots_size = { 0.8, 0.8 }

local i_s_s = 0.1
local p_container = table.concat({
  string.format("style_type[list;spacing=%s;size=%s,%s]", i_s_s, slots_size[1], slots_size[2]),
  string.format("list[current_player;main;0,0;%s,%s;%s]", sw_form.hotbar_size, sw_form.player_inv_col,
    sw_form.hotbar_size),
  string.format("list[current_player;main;0,%s;%s,1;0]", sw_form.player_inv_col,
    sw_form.hotbar_size),
})

local p_inv_size = { 25, 10 }
-- local everything
local row = 0
local col = 0
-- for item, def in pairs(core.registered_nodes) do
--   -- sw_form.button({ 0, 0 }, { 1, 1 }, "dirt", "not_dirt", "sw_nodes_dirt.png"),
--   all_nodes = all_nodes..string.format("item_image_button[%s,%s;1,1;%s;%s;%s]",col,row,item,item,item)
--   col = col +1
--   if col > 5 then
--     row = row +1
--     col = 0
--   end
-- end
local all_nodes = ""
for item, def in pairs(core.registered_items) do
  -- sw_form.button({ 0, 0 }, { 1, 1 }, "dirt", "not_dirt", "sw_nodes_dirt.png"),
  if item == "" or def.groups.not_in_creative_inventory ~= nil then
  else
    all_nodes = all_nodes ..
    string.format("item_image_button[%s,%s;1,1;%s;%s;%s]", col, row, item, item .. ":give", string.split(item, ":")[2])
    col = col + 1
    if col > 5 then
      row = row + 1
      col = 0
    end
  end
end

local p_inv = table.concat({
  "formspec_version[10]",
  string.format("size[%s,%s]", p_inv_size[1], p_inv_size[2]),
  sw_form.container({ 0, 0 }, p_inv_size, "#972453", {
    sw_form.container({ (sw_form.hotbar_size / 2.5), 0 },
      { sw_form.hotbar_size + (i_s_s * slots_size[1]), sw_form.player_inv_col + 2 }, "#849353", {
        p_container,
        -- "listring[current_player;main]",
      }),
    -- sw_form.container({ sw_form.hotbar_size + (i_s_s * slots_size[1]) + (sw_form.hotbar_size / 2), 0 }, { 6, 8 },
    -- "#242453", {
    sw_form.container({ 15, 0 }, { 6, 9 }, "#658345", {
      "scroll_container[0,0;6,9;yes;vertical;1;0.2]",
      string.format("style_type[image_button;border=false;bgimg=%s;bgimg_hovered=%s;font_size=10]",
        "(form_selectable.png^[multiply:#3a4a51)", "(form_selectable.png^[multiply:#9a4a51)"),
      all_nodes,
      "listring[]",
      "scroll_container_end[]",
      "scrollbar[6,0;0.5,9;vertical;yes;0]",
      string.format("image_button[%s,%s;%s,%s;%s;%s;%s]",0,9,1.5,1,"form_selectable.png","craft_size","1"),
      string.format("image_button[%s,%s;%s,%s;%s;%s;%s]",1.5,9,1.5,1,"form_selectable.png","craft_size","32"),
    })
    -- "listring[]",
    -- sw_form.button({ 0, 0 }, { 1, 1 }, "dirt", "not_dirt", "sw_nodes_dirt.png"),
    -- sw_form.button({ 0, 1 }, { 1, 1 }, "dirt", "not_dirt", "sw_nodes_cobblestone.png"),
    -- }),
  }),
})

function sw_form.defualt_inv(p_ref)
  p_ref:get_inventory():set_size("main", sw_form.hotbar_size * sw_form.player_inv_col)
  p_ref:hud_set_hotbar_itemcount(sw_form.hotbar_size)
  p_ref:set_inventory_formspec(p_inv)
end

sw_form.player_stacks = {}

function sw_form.getPlayerStacks(p_ref)
  local p_name = p_ref:get_player_name()
  sw_form.player_stacks[p_name] = sw_form.player_stacks[p_name] or {}
  return sw_form.player_stacks[p_name]
end

function sw_form.register_listener()
  core.register_on_player_receive_fields(function(p_ref, formname, fields)
    -- core.log("hmm: "..formname)
    -- core.get_player_window_information(player_name)
    if formname == "" then
      -- core.log("fields: " .. dump(fields))
      for key, value in pairs(fields) do
        if key ~= "quit" then
          local split = string.split(key, ":")
          if split[3] and split[3] == "give" then
            local p_control = p_ref:get_player_control()
            local itemstack = ItemStack(string.gsub(key, ":give", ""))
            -- core.log("player control: "..dump(p_control.sneak))
            local stacks = sw_form.getPlayerStacks(p_ref)
            if stacks.craft_size then
              itemstack:set_count(stacks.craft_size)
            end
            -- if p_control.sneak then
            --   itemstack:set_count(99)
            -- end
            p_ref:get_inventory():add_item("main", itemstack)
            core.sound_play(sw_sounds.pickup().dug, { pos = p_ref:get_pos(), to_player = p_ref:get_player_name() })
          end
          if key == "craft_size" then
            local stacks = sw_form.getPlayerStacks(p_ref)
            stacks.craft_size = value
            core.sound_play(sw_sounds.stone().dug, { pitch = 2.5, pos = p_ref:get_pos(), to_player = p_ref:get_player_name() })
          end
        end
      end
    end
  end)
end
