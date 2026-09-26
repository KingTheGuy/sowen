local mod_name = core.get_current_modname()
local mod_path = core.get_modpath(mod_name)

-- core.register_alias("mapgen_singlenode", "tc_nodes:stone")
-- core.register_alias("mapgen_stone", "tc_nodes:stone")
-- core.register_alias("mapgen_dirt", "tc_nodes:dirt")

core.register_biome({
  name = "tundra",

  -- node_dust = "tc_nodes:snow",
  -- Node dropped onto upper surface after all else is generated

  node_top = "tc_nodes:grass",
  depth_top = 1,
  -- Node forming surface layer of biome and thickness of this layer.
  -- Integer range of depth: [0, 32767]

  node_filler = "tc_nodes:dirt",
  depth_filler = 3,
  -- Node forming lower layer of biome and thickness of this layer.
  -- Integer range of depth: [0, 32767]

  node_stone = "tc_nodes:stone",
  -- Node that replaces all stone nodes between roughly y_min and y_max.

  -- node_water_top = "tc_nodes:ice",
  -- depth_water_top = 10,
  -- Node forming a surface layer in seawater with the defined thickness.
  -- Integer range of depth: [0, 32767]

  -- node_water = "",
  -- Node that replaces all seawater nodes not in the surface layer

  -- node_river_water = "tc_nodes:ice",
  -- Node that replaces river water in mapgens that use
  -- tc_nodes:river_water

  -- node_riverbed = "tc_nodes:gravel",
  -- depth_riverbed = 2,
  -- Node placed under river water and thickness of this layer.
  -- Integer range of depth: [0, 32767]

  -- node_cave_liquid = "tc_nodes:lava_source",
  -- node_cave_liquid = {"tc_nodes:water_source", "tc_nodes:lava_source"},
  -- Nodes placed inside 50% of the medium size caves.
  -- Multiple nodes can be specified, each cave will use a randomly
  -- chosen node from the list.
  -- If this field is left out or 'nil', cave liquids fall back to
  -- classic behavior of lava and water distributed using 3D noise.
  -- For no cave liquid, specify "air".

  node_dungeon = "tc_nodes:stone_bricks",
  -- Node used for primary dungeon structure.
  -- If absent, dungeon nodes fall back to the 'mapgen_cobble' mapgen
  -- alias, if that is also absent, dungeon nodes fall back to the biome
  -- 'node_stone'.
  -- If present, the following two nodes are also used.

  node_dungeon_alt = "tc_nodes:cobblestone",
  -- Node used for randomly-distributed alternative structure nodes.
  -- If alternative structure nodes are not wanted leave this absent.

  node_dungeon_stair = "stairs:stone_bricks",
  -- Node used for dungeon stairs.
  -- If absent, stairs fall back to 'node_dungeon'.

  y_max = 31000,
  y_min = 1,
  -- Upper and lower limits for biome.
  -- Alternatively you can use xyz limits as shown below.
  -- Integer [s16]

  max_pos = { x = 31000, y = 128, z = 31000 },
  min_pos = { x = -31000, y = 9, z = -31000 },
  -- xyz limits for biome, an alternative to using 'y_min' and 'y_max'.
  -- Biome is limited to a cuboid defined by these integer positions.
  -- Any x, y or z field left undefined tc_nodess to -31000 in 'min_pos' or
  -- 31000 in 'max_pos'.

  vertical_blend = 8,
  -- Vertical distance in nodes above 'y_max' over which the biome will
  -- blend with the biome above.
  -- Set to 0 for no vertical blend. tc_nodess to 0.
  -- Integer [s16]

  heat_point = 0.0,
  humidity_point = 50.0,
  -- Characteristic temperature and humidity for the biome.
  -- These values create 'biome points' on a voronoi diagram with heat and
  -- humidity as axes. The resulting voronoi cells determine the
  -- distribution of the biomes.
  -- Heat and humidity have average values of 50.0, vary mostly between
  -- 0.0 and 100.0 but can exceed these values.

  weight = 1.0,
  -- Relative weight of the biome in the Voronoi diagram.
  -- A value of 0 (or less) is ignored and equivalent to 1.0.
})

core.register_decoration({
  deco_type = "schematic",
  place_on = { "group:soil" },
  sidelen = 16,
  fill_ratio = 0.0006,
  biomes = { "tundra" },
  y_min = -31000,
  y_max = 31000,
  schematic = mod_path.."/schematics/tree1.mts",
  flags = "place_center_x, place_center_z",
  rotation = "random",
  -- replacements = {["oldname"] = "convert_to", ...}, --replace corner nodes
  _layer = 35,
  place_offset_y = 1,
})

core.register_decoration({
  deco_type = "schematic",
  place_on = { "group:soil" },
  sidelen = 16,
  fill_ratio = 0.0006,
  biomes = { "tundra" },
  y_min = -31000,
  y_max = 31000,
  schematic = mod_path.."/schematics/tree2.mts",
  flags = "place_center_x, place_center_z",
  rotation = "random",
  _layer = 35,
  place_offset_y = 1,
})

core.register_decoration({
  deco_type = "schematic",
  place_on = { "group:soil" },
  sidelen = 16,
  fill_ratio = 0.0006,
  biomes = { "tundra" },
  y_min = -31000,
  y_max = 31000,
  schematic = mod_path.."/schematics/tree3.mts",
  flags = "place_center_x, place_center_z",
  rotation = "random",
  _layer = 35,
  place_offset_y = 1,
})

core.register_decoration({
  deco_type = "simple",
  place_on = { "tc_nodes:grass","tc_nodes:dirt" },
  sidelen = 16,
  fill_ratio = 0.2,
  biomes = { "tundra" },
  y_min = -31000,
  y_max = 31000,
  decoration = "tc_nodes:tall_grass",
  -- schematic = "../schematics/tree1.we",
  flags = "place_center_x, place_center_z",
  rotation = "random",
  _layer = 35,
})
