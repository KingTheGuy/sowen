local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

---TODO: this needs to be a functon that will also be run with ondrop() function
-- core.register_on_item_pickup(function(itemstack, picker, pointed_thing, time_from_last_punch,...)
--   -- core.log(dump(picker).."-> picked up: "..dump(itemstack))
--   -- core.log("something should be happening")
--   core.chat_send_player(picker:get_player_name(),string.format("added %s x%s",string.gsub(string.split(itemstack:get_name(),":")[2],"_"," "),itemstack:get_count()))

-- end)

---@class pickupHud
---@field id
---@field timeout
---@field text

sw_init.player_huds = {}

local function getPlayerHud(p_name)
  sw_init.player_huds[p_name] = sw_init.player_huds[p_name] or {}
  return sw_init.player_huds[p_name]
end

---NOTE: the indicator should just handle, rendering
---TODO: add all of this to the pickup function
function sw_init.pickup_indicator(player, item_or_msg, amount)
  local msg = ""
  if amount == nil then
    msg = item_or_msg
  else
    local p_inv = player:get_inventory():get_list("main")
    local all_stack = 0
    for _, stack in ipairs(p_inv) do
      if stack:get_name() == item_or_msg then
        all_stack = all_stack + stack:get_count()
      end
    end
    -- core.log("inv: "..dump(p_inv))
    msg = string.format("added %s x%s", string.gsub(string.split(item_or_msg, ":")[2], "_", " "), all_stack)
  end


  local p_hud = getPlayerHud(player:get_player_name())
  p_hud.pickup_hud = p_hud.pickup_hud or {}
  p_hud.pickup_hud.timeout = 20 * 6
  msg = " + " .. msg
  p_hud.text = msg
  if p_hud.pickup_hud.id == nil then
    --create the hud
    p_hud.pickup_hud.id = player:hud_add({
      type = "text",
      name = "pickup hud",          -- string
      text = msg,
      number = "0xFFFFFF",          -- integer with range [u32]
      position = { x = 0.01, y = 0.21 },
      alignment = { x = 1, y = 0 }, -- two numbers
      scale = { x = 1, y = 1 },     -- two numbers
    })
  else
    --update the hud
    player:hud_change(p_hud.pickup_hud.id, "text", msg)
    player:hud_change(p_hud.pickup_hud.id, "position", { x = 0.01, y = 0.21 })
  end
  -- core.chat_send_player(clicker:get_player_name(),string.format("Inventory is full.."))
end

local tick = 0
--- clear the hud after a few seconds
core.register_globalstep(function(dtime)
  -- tick = tick + 1
  -- if tick >= 20 then
  for p_name, hud in pairs(sw_init.player_huds) do
    ---type pickupHud
    if hud.pickup_hud ~= nil then
      hud.pickup_hud.timeout = hud.pickup_hud.timeout - 1
      local p_ref = core.get_player_by_name(p_name)
      if p_ref ~= nil then
        -- local updated_text = string.sub(hud.text, 2, #hud.text)
        local updated_text = hud.text
        hud.text = updated_text
        p_ref:hud_change(hud.pickup_hud.id, "text", updated_text)
        local pos = p_ref:hud_get(hud.pickup_hud.id).position
        if pos.y > 0.15 then
          pos.y = pos.y - 0.01
        end
        p_ref:hud_change(hud.pickup_hud.id, "position", { x = pos.x, y = pos.y })
        if hud.pickup_hud.timeout <= 0 then
          p_ref:hud_remove(hud.pickup_hud.id)
          sw_init.player_huds[p_name].pickup_hud = nil
          -- elseif hud.pickup_hud.timeout >= 4 then
          --   p_ref:hud_change(hud.pickup_hud.id, "position", { x = 0.01, y = 0.2 })
        end
      end
    end
  end
  -- tick = 0
  -- end
end)
