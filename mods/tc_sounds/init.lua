local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

tc_sounds = {}

function tc_sounds.stone()
  return {
    footstep = {
      name = "tc_stone_footstep"
    },
    place = {
      name = "tc_stone_footstep"
    },
    dig = {
      name = "tc_stone_footstep",
      pitch = 0.8,
    },
    dug = {
      name = "tc_stone_footstep",
      pitch = 0.7,
    },
  }
end


function tc_sounds.dirt()
  return {
    footstep = {
      name = "tc_dirt_footstep"
    },
    place = {
      name = "tc_dirt_footstep"
    },
    dig = {
      name = "tc_dirt_footstep"
    },
    dug = {
      name = "tc_dirt_footstep"
    },
  }
end

function tc_sounds.plant()
  return {
    footstep = {
      name = "tc_plant_footstep"
    },
    place = {
      name = "tc_plant_footstep"
    },
    dig = {
      name = "tc_plant_footstep"
    },
    dug = {
      name = "tc_plant_footstep"
    },
  }
end


function tc_sounds.pickup()
  return {
    footstep = {
      name = "tc_plank_footstep"
    },
    place = {
      name = "tc_plank_footstep"
    },
    dig = {
      name = "tc_plank_footstep"
    },
    dug = {
      name = "tc_plank_footstep",
      pitch = 2.7,
      gain = 2.0,
    },
  }
end

function tc_sounds.plank()
  return {
    footstep = {
      name = "tc_plank_footstep"
    },
    place = {
      name = "tc_plank_footstep"
    },
    dig = {
      name = "tc_plank_footstep"
    },
    dug = {
      name = "tc_plank_footstep",
    },
  }
end
