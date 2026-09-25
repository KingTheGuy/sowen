local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

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

rope = {}

---TODO: rope anchor, if anchor is not there, remove rope. and remove other anchor.. if anchor is not another type of entity
---FIXME: need to normalize all values, cant have negatives
-- function rope.update_visual(self,pos1,pos2)
--     self.object:set_rotation(vector.new(0,0,0))
--     local m_pos = pos1
--     local s_pos = pos2
--     if pos2.y > pos1.y then
--       m_pos = pos2
--       s_pos = pos1
--       -- if m_pos.x < s_pos.x then
--       --   local x = m_pos.x
--       --   m_pos.x = s_pos.x
--       --   s_pos.x = x
--       -- end
--     end
--     ---if pos1.x is bigger than pos2.x swap them
--     local mid = m_pos:add(s_pos):divide(2)
--     local rot = math.atan(mid.z - s_pos.z, mid.x - s_pos.x)

--     local distance = vector.distance(m_pos, mid)
--     local vertical = math.deg(math.atan(mid.y - m_pos.y, mid.x - m_pos.x))
--     --get lowest z.. of the positions.. if pos.y is lower flip it
--     local height_dif = m_pos:subtract(s_pos)
--     if vertical ~= 0 then
--       vertical = vertical + math.deg(math.rad(16))
--       if m_pos.x > mid.x then
--         if s_pos.y < m_pos.y then
--           -- rot = math.rad(math.deg(rot) + 180)
--           -- vertical = (vertical/2)
--         end
--       else
--         if mid.y < m_pos.y then
--           rot = math.rad(math.deg(rot) + 180)
--         end
--       end
--     end
--     local stretch = (16 * distance)+(height_dif.y/2)
--     self.object:set_properties({
--       visual_size = { x = stretch, y = 16, z = 16 },
--     })
--     -- local degrees = (math.deg(rot) + 360) % 360
--     -- core.log("angle: " .. rot)
--     -- vertical = 0
--     if mid.z < m_pos.z then
--       rot = math.atan(mid.z+m_pos.z,mid.x+m_pos.x)
--       rot = math.rad(math.deg(rot) + 180)
--     end

--     -- core.log("rot: "..rot)
--     self.object:set_rotation(vector.new(0, rot, math.rad(vertical)))
-- end

function rope.update_visual(self, pos1, pos2)
  --- COLOR ---
  if string.find(self.name,"flag") then
    local color_index = self._color1
    if self._t_flip == 1 then
        color_index = self._color2
      else
        color_index = self._color1
    end
    if color_index == nil or color_index == 0 then
      color_index = 0
    end
    -- local color = string.format("nanner-pancakes-1x.png^[sheet:256x1:%s,0", color_index)
    local color = function(index)
      return string.format(tc_init.color_palette.."^[sheet:256x1:%s,0", index)
    end
    local texture = core.registered_entities[self.name].initial_properties.textures[1]

    ---TODO:
    -- get flag area -< apply color to area -< make full texure
    self.object:set_properties({
      textures = { string.format("[fill:16x16:#fff^(%s^[resize:5x16)^(%s^[resize:5x5)^[mask:%s",color(self._color1),color(self._color2),texture) }
    })
  end

  -- self.object:set_rotation(vector.new(0,0,0))
  -- core.log("name: "..self.name)
  self.object:set_pos(pos1:add(pos2):divide(2))
  -- vector.distance handles negative coordinates safely via math.sqrt(dx^2 + dy^2 + dz^2)
  local dist = vector.distance(pos1, pos2)
  -- core.log("distance: " .. dist)
  -- if dist < 0.001 then return end

  -- vector.direction(pos1, pos2) does (pos2 - pos1) and normalizes it.
  -- Negative signs cancel out correctly.
  local dir = vector.direction(pos1, pos2)
  -- local dir = vector.direction(pos1, pos1:add(pos2):divide(2))

  -- vector.dir_to_rotation uses atan2 under the hood, handling 360-degree direction
  local rot = vector.dir_to_rotation(dir)
  -- rot.x=0
  -- rot.y = rot.y + math.rad(90)
  self.object:set_rotation(rot)

  local stretch = (16 * dist / 2)
  if self.name == "tc_entities:chain" then
    if dist < 3 then
      self.object:set_properties({
        visual_size = { x = 16, y = 16, z = stretch },
        mesh = "chain.glb",
      })
    elseif dist > 3 and dist < 6 then
      self.object:set_properties({
        visual_size = { x = 16, y = 16, z = stretch / 2 },
        mesh = "chain_long.glb",
      })
    elseif dist > 6 and dist < 8 then
      self.object:set_properties({
        visual_size = { x = 16, y = 16, z = stretch / 3 },
        mesh = "chain_longer.glb",
      })
    elseif dist > 8 then
      self.object:set_properties({
        visual_size = { x = 16, y = 16, z = stretch/3},
        mesh = "chain_longer.glb",
      })
    end
  else
    self.object:set_properties({
      visual_size = { x = 16, y = 16, z = stretch }
    })
  end
  if self.name == "tc_entities:bunting_flags" then
    -- if stretch > 10 then
    --   self.object:set_properties({
    --     visual_size = { x = 16, y = 16, z = stretch / 2 },
    --     mesh = "bunting_flags.glb",
    --   })
    if dist < 3 then
      self.object:set_properties({
        visual_size = { x = 16, y = 16, z = 16 },
        mesh = "bunting_flags.glb",
      })
    elseif dist > 3 then
      self.object:set_properties({
        visual_size = { x = 16, y = 16, z = stretch / 2 },
        mesh = "bunting_flags_2.glb",
        -- textures = { "tc_entities_bunting_flags.png^(tc_entities_bunting_flags.png)" },
      })
      -- elseif dist > 6 then
      --   local size = 16 * 2
      --   core.log("size: "..size)
      --   local texture = "tc_entities_bunting_flags_tileable.png"
      --   local tiled_texture = string.format("[combine:%sx16:0,0=%s:16,0=%s", size, texture, texture)
      --   self.object:set_properties({
      --     visual_size = { x = 16, y = 16, z = stretch},
      --     mesh = "bunting_flags_tileable.glb",
      --     -- textures = { "tc_entities_bunting_flags.png^(tc_entities_bunting_flags.png)" },
      --     textures = { tiled_texture },
      --   })
    end
  end
end

core.register_entity(mod_name .. ":rope", {
  initial_properties = {
    visual = "mesh",
    mesh = "rope.glb",
    textures = { "tc_entities_rope.png" },
    visual_size = { x = 16, y = 16, z = 16 },
    backface_culling = false,
  },
  _the_static_data = {
    -- "_tick",
    "_pos1",
    "_pos2",
    "_placer",
  },
  shaded = false,
  -- A table of object properties, see the `Object properties` section.
  -- The properties in this table are applied to the object
  -- once when it is spawned.
  get_staticdata = function(self)
    return get_staticdata(self)
  end,
  on_activate = function(self, staticdata, dtime_s)
    on_activate(self, staticdata, dtime_s)
    -- for key, value in pairs(self) do
    --   core.log(dump(key)..": "..dump(value))
    -- end
    if self._pos1 == nil or self._pos2 == nil then
      return
    end
    local pos1 = vector.from_string(self._pos1)
    local pos2
    if type(self._pos2) == "table" then
      pos2 = self._pos2
    else
      pos2 = vector.from_string(self._pos2)
    end
    rope.update_visual(self, pos1, pos2)
  end,

  on_deactivate = function(self, removal) end,
  on_step = function(self, dtime, moveresult)
    if self._placer ~= nil then
      local pos1 = vector.from_string(self._pos1)
      if type(self._placer) ~= "string" then
        local offset = self._placer:get_pos():add(vector.new(0, 1, 0))
        rope.update_visual(self, pos1, offset)
      end
    end
  end,
  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    self.object:remove()
  end,
  on_death = function(self, killer) end,
  on_rightclick = function(self, clicker) end,
  on_attach_child = function(self, child) end,
  on_detach_child = function(self, child) end,
  on_detach = function(self, parent) end,

  -- _custom_field = whatever,
  -- You can define arbitrary member variables here (see Item definition
  -- for more info) by using a '_' prefix
})



core.register_entity(mod_name .. ":rope_thick", {
  initial_properties = {
    visual = "mesh",
    mesh = "rope_thick.glb",
    textures = { "tc_entities_rope_thick.png" },
    visual_size = { x = 16, y = 16, z = 16 },
    backface_culling = false,
  },
  _the_static_data = {
    -- "_tick",
    "_pos1",
    "_pos2",
    "_placer",
  },
  shaded = false,
  -- A table of object properties, see the `Object properties` section.
  -- The properties in this table are applied to the object
  -- once when it is spawned.
  get_staticdata = function(self)
    return get_staticdata(self)
  end,
  on_activate = function(self, staticdata, dtime_s)
    on_activate(self, staticdata, dtime_s)
    -- for key, value in pairs(self) do
    --   core.log(dump(key)..": "..dump(value))
    -- end
    if self._pos1 == nil or self._pos2 == nil then
      return
    end
    local pos1 = vector.from_string(self._pos1)
    local pos2
    if type(self._pos2) == "table" then
      pos2 = self._pos2
    else
      pos2 = vector.from_string(self._pos2)
    end
    rope.update_visual(self, pos1, pos2)
  end,

  on_deactivate = function(self, removal) end,
  on_step = function(self, dtime, moveresult)
    if self._placer ~= nil then
      local pos1 = vector.from_string(self._pos1)
      if type(self._placer) ~= "string" then
        local offset = self._placer:get_pos():add(vector.new(0, 1, 0))
        rope.update_visual(self, pos1, offset)
      end
    end
  end,
  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    self.object:remove()
  end,
  on_death = function(self, killer) end,
  on_rightclick = function(self, clicker) end,
  on_attach_child = function(self, child) end,
  on_detach_child = function(self, child) end,
  on_detach = function(self, parent) end,

  -- _custom_field = whatever,
  -- You can define arbitrary member variables here (see Item definition
  -- for more info) by using a '_' prefix
})



core.register_entity(mod_name .. ":chain", {
  initial_properties = {
    visual = "mesh",
    mesh = "chain.glb",
    textures = { "tc_entities_chain.png" },
    visual_size = { x = 16, y = 16, z = 16 },
    backface_culling = false,
  },
  _the_static_data = {
    -- "_tick",
    "_pos1",
    "_pos2",
    "_placer",
  },
  shaded = true,
  -- A table of object properties, see the `Object properties` section.
  -- The properties in this table are applied to the object
  -- once when it is spawned.
  get_staticdata = function(self)
    return get_staticdata(self)
  end,
  on_activate = function(self, staticdata, dtime_s)
    on_activate(self, staticdata, dtime_s)
    -- for key, value in pairs(self) do
    --   core.log(dump(key)..": "..dump(value))
    -- end
    if self._pos1 == nil or self._pos2 == nil then
      return
    end
    local pos1 = vector.from_string(self._pos1)
    local pos2
    if type(self._pos2) == "table" then
      pos2 = self._pos2
    else
      pos2 = vector.from_string(self._pos2)
    end
    rope.update_visual(self, pos1, pos2)
  end,

  on_deactivate = function(self, removal) end,
  on_step = function(self, dtime, moveresult)
    if self._placer ~= nil then
      local pos1 = vector.from_string(self._pos1)
      if type(self._placer) ~= "string" then
        local offset = self._placer:get_pos():add(vector.new(0, 1, 0))
        rope.update_visual(self, pos1, offset)
      end
    end
  end,
  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    self.object:remove()
  end,
  on_death = function(self, killer) end,
  on_rightclick = function(self, clicker) end,
  on_attach_child = function(self, child) end,
  on_detach_child = function(self, child) end,
  on_detach = function(self, parent) end,

  -- _custom_field = whatever,
  -- You can define arbitrary member variables here (see Item definition
  -- for more info) by using a '_' prefix
})

core.register_entity(mod_name .. ":bunting_flags", {
  initial_properties = {
    visual = "mesh",
    mesh = "bunting_flags.glb",
    textures = { "tc_entities_bunting_flags.png" },
    visual_size = { x = 16, y = 16, z = 16 },
    backface_culling = false,
  },
  _the_static_data = {
    -- "_tick",
    "_pos1",
    "_pos2",
    "_placer",
    "_color1",
    "_color2",
  },
  _paintable  = "true",
  shaded = true,
  -- A table of object properties, see the `Object properties` section.
  -- The properties in this table are applied to the object
  -- once when it is spawned.
  get_staticdata = function(self)
    return get_staticdata(self)
  end,
  on_activate = function(self, staticdata, dtime_s)
    on_activate(self, staticdata, dtime_s)
    -- for key, value in pairs(self) do
    --   core.log(dump(key)..": "..dump(value))
    -- end
    if self._pos1 == nil or self._pos2 == nil then
      return
    end
    local pos1 = vector.from_string(self._pos1)
    local pos2
    if type(self._pos2) == "table" then
      pos2 = self._pos2
    else
      pos2 = vector.from_string(self._pos2)
    end
    rope.update_visual(self, pos1, pos2)
  end,

  on_deactivate = function(self, removal) end,
  on_step = function(self, dtime, moveresult)
    if self._placer ~= nil then
      local pos1 = vector.from_string(self._pos1)
      if type(self._placer) ~= "string" then
        local offset = self._placer:get_pos():add(vector.new(0, 1, 0))
        rope.update_visual(self, pos1, offset)
      end
    end
  end,
  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    self.object:remove()
  end,
  on_death = function(self, killer) end,
  on_rightclick = function(self, clicker) end,
  on_attach_child = function(self, child) end,
  on_detach_child = function(self, child) end,
  on_detach = function(self, parent) end,

  _color1 = 0,
  _color2 = 0,
  -- _custom_field = whatever,
  -- You can define arbitrary member variables here (see Item definition
  -- for more info) by using a '_' prefix
})
