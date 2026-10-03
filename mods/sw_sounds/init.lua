local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

sw_sounds = {}

function sw_sounds.stone()
  return {
    footstep = {
      name = "stone_footstep"
    },
    place = {
      name = "stone_footstep"
    },
    dig = {
      name = "stone_footstep",
      pitch = 0.8,
    },
    dug = {
      name = "stone_footstep",
      pitch = 0.7,
    },
  }
end

function sw_sounds.leaves()
  return {
    footstep = {
      name = "leaves_footstep",
      -- pitch = 1.7,
    },
    place = {
      name = "leaves_footstep"
    },
    dig = {
      name = "leaves_footstep"
    },
    dug = {
      name = "leaves_footstep"
    },
  }
end


function sw_sounds.pickup()
  return {
    footstep = {
      name = "pickup"
    },
    place = {
      name = "pickup"
    },
    dig = {
      name = "pickup"
    },
    dug = {
      name = "pickup",
      pitch = 1.8,
      gain = 1.5,
    },
  }
end

function sw_sounds.grass()
  return {
    footstep = {
      name = "grass_footstep",
      -- pitch = 1.8,
      gain = 0.5,
    },
    place = {
      name = "grass_footstep"
    },
    dig = {
      name = "grass_footstep"
    },
    dug = {
      name = "grass_footstep"
    },
  }
end

function sw_sounds.dirt()
  return {
    footstep = {
      name = "dirt_footstep"
    },
    place = {
      name = "dirt_footstep",
      gain = 1.5,
      pitch = 1.5,
    },
    dig = {
      name = "dirt_footstep"
    },
    dug = {
      name = "dirt_footstep"
    },
  }
end

function sw_sounds.wood()
  return {
    footstep = {
      name = "wood_footstep",
      -- pitch = 1.5,
      -- gain = 1.0,
    },
    place = {
      name = "wood_footstep"
    },
    dig = {
      name = "wood_footstep"
    },
    dug = {
      name = "wood_footstep"
    },
  }
end
