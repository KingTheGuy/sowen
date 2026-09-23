tc_init.despawn_time = 60 * 2

local function on_activate(self, staticdata, dtime_s)
  local data = core.deserialize(staticdata)
  if data then
    for key, val in pairs(data) do
      self[key] = val
    end
  end
end

local function get_staticdata(self)
  local data = {}
  if self._the_static_data ~= nil then
    for i, key in pairs(self._the_static_data) do
      if key then
        if core.is_player(self[key]) or (type(self[key]) == "table" and self[key].object) then
          error("NO, YOU CANNOT SERIALIZE AN OBJECT!!! from: " .. key)
        end
        data[key] = self[key]
      end
    end
  end
  return core.serialize(data)
end

local item_entity = core.registered_entities["__builtin:item"]
local item_on_step = item_entity.on_step
local item_on_activate = item_entity.on_activate
item_entity._the_static_data = {
  "_tick",
  "_dropped",
  "_stacksize",
  "itemstring",
  "_despawn"
}

item_entity.get_staticdata = function(self)
  return get_staticdata(self)
end

item_entity.on_activate = function(self, staticdata, dtime_s)
  item_on_activate(self, staticdata, dtime_s)
  on_activate(self, staticdata, dtime_s)
end

item_entity.on_step = function(self, dtime, moveresult)
  item_on_step(self, dtime, moveresult)

  local stacksize = tonumber(string.split(self.itemstring, " ")[2])

  --- increment the timer
  if self._tick == nil then self._tick = 0 end
  self._tick = self._tick + dtime

  --- reset the timer if stacksize changes
  if self._stacksize ~= nil then
    if self._stacksize ~= stacksize then
      self._stacksize = stacksize
      self._despawn = tc_init.despawn_time
    end
  else
    self._stacksize = stacksize
  end

  -- if self._dropped == 1 then
  local pos = self.object:get_pos()
  if self._tick >= 1 then
    core.add_particle({
      size = 8,
      pos = pos,
      -- texture = "[fill:1x1:" .. "#fff",
      texture = "tc_items_item_particle.png^[opacity:200",
      velocity = vector.new(0,0.8,0),
      expirationtime = 1,
      glow = 14,
    })
    core.add_particle({
      size = 8,
      pos = self.object:get_pos(),
      -- texture = "[fill:1x1:" .. "#fff",
      texture = "tc_items_drop_bg.png^[opacity:40",
      -- velocity = vector.new(0, 1, 0),
      expirationtime = 1,
      glow = 14,
    })
  end
  -- end

  if self._despawn == nil then self._despawn = tc_init.despawn_time end
  if self._despawn <= 0 then
    self.object:remove()
  end

  if self._tick >= 1 then
    self._despawn = self._despawn - 1
    self._tick = 0
  end
  -- core.log("now we do our own thing")
end

item_entity.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
end

item_entity.on_rightclick = function(self, clicker)
  local itemstring = string.split(self.itemstring, " ")
  local itemstack = ItemStack(itemstring[1])
  local stack_size = itemstring[2]
  if itemstring == nil then
    -- core.log("no stack")
    return
  end
  if stack_size == nil then
    stack_size = 1
    -- core.log("no stack size")
    -- return
  end
  itemstack:set_count(stack_size)

  local left_over = core.item_pickup(itemstack, clicker)

  -- core.log("itemstack: "..dump(itemstack))

  if tonumber(stack_size) == tonumber(left_over:get_count()) then
    tc_init.pickup_indicator(clicker, "Inventory is full..")
  else
    local added = stack_size - left_over:get_count()
    tc_init.pickup_indicator(clicker, itemstack:get_name(), added)
    core.sound_play(tc_sounds.pickup().dug, { pos = clicker:get_pos()})
  end


  if left_over:get_count() <= 0 then
    self.object:remove()
  else
    self.itemstring = string.format("%s %s", itemstring[1], left_over:get_count())
  end

  -- core.log("what are we doing?")
  -- core.item_pickup(itemstack, picker, pointed_thing, time_from_last_punch, ...)
end
