local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

tc_form = {}

dofile(mod_path .. "/../tc_sounds/init.lua")

---FORM STUFF (should move)
function tc_form.container(pos, size, bg_color, content)
  return table.concat({
    string.format("container[%s,%s]", pos[1], pos[2]),
    string.format("box[%s,%s;%s,%s;%s]", 0, 0, size[1], size[2], bg_color),
    table.concat(content),
    "container_end[]",
  })
  -- return string.format("container[%s,%s]%scontainer_end[]", pos[1], pos[2], table.concat(content))
end

function tc_form.button(pos, size, name, label, image)
  return table.concat({
    string.format("tooltip[%s,%s;%s,%s;%s]", pos[1], pos[2], size[1], size[2], name),
    string.format("image_button[%s,%s;%s,%s;%s;%s;;true;false]", pos[1], pos[2], size[1], size[2], image, label)
  })
end

tc_form.hotbar_size = 11
tc_form.player_inv_col = 5
-- tc_form.inv_hotbar_padding = 0.5

local slots_size = { 0.8, 0.8 }

local i_s_s = 0.1
local p_container = table.concat({
  string.format("style_type[list;spacing=%s;size=%s,%s]", i_s_s, slots_size[1], slots_size[2]),
  string.format("list[current_player;main;0,0;%s,%s;%s]", tc_form.hotbar_size, tc_form.player_inv_col,
    tc_form.hotbar_size),
  string.format("list[current_player;main;0,%s;%s,1;0]", tc_form.player_inv_col,
    tc_form.hotbar_size),
})

local p_inv_size = { 25, 10 }
-- local everything
local row = 0
local col = 0
-- for item, def in pairs(core.registered_nodes) do
--   -- tc_form.button({ 0, 0 }, { 1, 1 }, "dirt", "not_dirt", "tc_nodes_dirt.png"),
--   all_nodes = all_nodes..string.format("item_image_button[%s,%s;1,1;%s;%s;%s]",col,row,item,item,item)
--   col = col +1
--   if col > 5 then
--     row = row +1
--     col = 0
--   end
-- end
local all_nodes = ""
for item, def in pairs(core.registered_items) do
  -- tc_form.button({ 0, 0 }, { 1, 1 }, "dirt", "not_dirt", "tc_nodes_dirt.png"),
  if item == "" or def.groups.not_in_creative_inventory ~= nil then
  else
    all_nodes = all_nodes .. string.format("item_image_button[%s,%s;1,1;%s;%s;%s]", col, row, item, item .. ":give", "")
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
  tc_form.container({ 0, 0 }, p_inv_size, "#972453", {
    tc_form.container({ (tc_form.hotbar_size / 2.5), 0 },
      { tc_form.hotbar_size + (i_s_s * slots_size[1]), tc_form.player_inv_col + 2 }, "#849353", {
        p_container,
        -- "listring[current_player;main]",
      }),
    -- tc_form.container({ tc_form.hotbar_size + (i_s_s * slots_size[1]) + (tc_form.hotbar_size / 2), 0 }, { 6, 8 },
    -- "#242453", {
    "scroll_container[15,0;6,9;yes;vertical;1;0.2]",
    string.format("style_type[image_button;border=false;bgimg=%s;bgimg_hovered=%s]",
      "(form_selectable.png^[multiply:#3a4a51)", "(form_selectable.png^[multiply:#9a4a51)"),
    all_nodes,
    "listring[]",
    "scroll_container_end[]",
    "scrollbar[21,0;0.5,9;vertical;yes;0]"
    -- "listring[]",
    -- tc_form.button({ 0, 0 }, { 1, 1 }, "dirt", "not_dirt", "tc_nodes_dirt.png"),
    -- tc_form.button({ 0, 1 }, { 1, 1 }, "dirt", "not_dirt", "tc_nodes_cobblestone.png"),
    -- }),
  }),
})

function tc_form.defualt_inv(p_ref)
  p_ref:get_inventory():set_size("main", tc_form.hotbar_size * tc_form.player_inv_col)
  p_ref:hud_set_hotbar_itemcount(tc_form.hotbar_size)
  p_ref:set_inventory_formspec(p_inv)

  core.register_on_player_receive_fields(function(player, formname, fields)
    -- core.log("hmm: "..formname)
    -- core.get_player_window_information(player_name)
    if formname == "" then
      -- core.log("fields: " .. dump(fields))
      for key, value in pairs(fields) do
        if key ~= "quit" then
          local split = string.split(key, ":")
          if split[3] and split[3] == "give" then
            local p_control = player:get_player_control()
            local itemstack = ItemStack(string.gsub(key, ":give", ""))
            -- core.log("player control: "..dump(p_control.sneak))
            if p_control.sneak then
              itemstack:set_count(99)
            end
            player:get_inventory():add_item("main", itemstack)
            core.sound_play(tc_sounds.pickup().dug, { pos = player:get_pos(), to_player = player:get_player_name() })
          end
        end
      end
    end
  end)
end
