# TODO:

### rotation stuff:

0 20
1 23
2 22
3 21

0 8
1 17
2 6
3 15

- [ ] figure out game name
  - Rooted
  - The Core (current name, comes from MC hardcore season... does not sound cozy, thought this is not really a 100% cozy game)
  - Dusty (not sure I'd want to use this as game name)
  - Bloodness Crown (cant see people calling it this, or it fitting the game)
  - Sowed (may be too short)

# BACKLOG:

- [ ] custom made drop item entity
  - for more control over how it behaves
  - [ ] layer; for particles
  - [ ] layer; for outline

- [ ] texture aligned to work maybe does not work as well as I'd like
- [ ] idea: shoveling.
  - removes in 3x3-ish area
  - removes layers, gives player clump_of_dirt
  - to remove 1 node entirely use pickaxe
  - NOTE: I am not really sure if this is a good idea

- [ ] on **buildable_to** have it play the dug sound of the node

- [ ] builds need support?
  - as in like block/nodes can fall/break if they do not have something below them supporting them up.

- [ ] guide menu/ guide tree / advancement tree
  - lets not have the player guess how things work

- [ ] entering water should affect fog distance

- [ ] maybe hostile mobs should become harder as the days pass?
  - or harder ones spawn in as you reach milestones.

- [ ] thin logs, add a variant that fills in spacing with insulation (think log cabin)
  - variant node? or entity?

- [ ] stairs, panels. let's have this these be created by using a tool on the main node

- [ ] submerged nodes
  - to not have to deal with air gaps
  - stairs in water, with snow, etc
  - this may require additional modeling?

- [ ] saplings
  - should have 2 textures, one small sapling, one small tree.. which will then finish growing to a full tree

- [ ] add stick
  - can be placed
  - if possible will take the texture/color of the wood node that it gets placed on
  - what would this accomplish though?

- [ ] multi offhands
  - main hotbar, each slot has a secondary slot. can pair block with torch, spear with shield, block with chisel_and_hammer.. etc.

# DOING:

- [ ] rope
  - currently just a simple visual thing
  - [ ] end points

- [ ] color palettes
  - [ ] paint_brush color menu
  - [ ] paint_brush
  - [ ] chisel_and_hammer needs to keep the color/param2 when switching nodes
  - [ ] painting a node should keep the rotation/or param2
  - sadly colorfacedir only supports 8 colors.
    - [ ] ? add a popup message that says "cant use this color" and give it some of the main colors (put the main 8 colors at the front of the palette)
    - [ ] ? switch facedir to 4dir and replace node with 2 variants, one normal and one upside-down (rather not go this route)

- [ ] node,stairs,step,panels **definition**
  - defining the main node also defines the variants

- [ ] chisel_and_hammer, just for simple variants of node in use

- [ ] wood_cutter/stone_cutter..etc. will provide extra nodes of which the chisel_and_hammer can then be used for the variants

- [x] indicator that tells the they have picked up something

- [ ] node drops
  - should be somewhat similar to the node drop table
  - ??? hmm how should I do this?
  - [ ] take into account tool
  - [ ] take into account tool group
  - groups / tool_capabilities; groupcaps... are annoying and confusing to deal with

- [x] water
- [ ] grass
- [ ] tall grass
- [ ] rocks
- [ ] trees

- [x] override item entity
  - [x] when dropped from nodes have a particle show up; but if dropped by the player, don't
  - [x] make it persistent (make sure \_dropped is saved)
  - [ ] can I clean this up a bit?

- [ ] global tick, check player inv, and move dropped item into player's inventory?

**figure out how involved this should be**

- I do want players to be able to start building their base early on without much of any struggle.

- less UIs, zero crafting grids.

## key features:

- temperature

## not sure:

- do I want it so that animals need to be "looted"? I don't really think so as it would take away from it ever feeling cozy
- shelter system?(pretty much force the player to build) workbenches need to be covered?

## gameplay:

_early on:_

- cant "mine" wood or stone with hands (tool is needed)
- pickup sticks, rocks, and flint from the ground to make [tools](#tools)
- create a [flint knife](#knifes); to start gathering [plant fiber](#plant-fiber) from grass
- create a [campfire](#campfire); light with [fire starter](#fire-starter)
- start gathering food;
- creating planks: [chopping block](#chopping-block), place log on chopping block and use an [axe](#tools) on it.
- build shelter; to stay safe from [[#hostile mobs]]

### chopping block

created by using sharp flint/rock on a log.

_usage:_

- chop logs down into planks
- chop planks down into stick
- convert one wood product down into another

### plant fiber

Can be used to bind things together...
Gathered from grass using a [knife](#tools)

_usage:_

- for making tools
- for making caring sacks

### fire starter

used to spark fires

_in [[#crafting menu]]:_

[[#plant fiber]], flint and rock

#### campfire

- cooks meat
- used to keep the player warm
- if well fed with give the player regen

_usage:_

- keep the fire alive by supplying it with logs, sticks, or [plant fiber](#plant-fiber)

### cutting board

similar to a [[#chopping block]]

### tools

- [[#knifes]]
- axe; used to mine wood
- pickaxe; used to mine stones & soils
- spear; throwable
- sword
- hammer

?should these next tools require [plant fiber](#plant-fiber)?
It would force the player to start looking for [[#plant fiber]] before they can start chopping down a tree.

_flint_:

first set of tools

_bone_:

same as flint, are a bit faster, but they have less usage.

#### knifes

a tool with many uses

_usage:_

_animals:_

- killing an animal; will result in an increased amount of drops from the animal.
- right_clicking will do a secondary non-lethal action on the animal; crude way of getting wool from sheep or other.

_grass:_

- breaking; grass will result in [[#plant fiber]]
- right_click; will extract seeds

_crops:_

- breaking; will gather the resources without removing the crop.
- right_click; nothing.

_[cutting board](#cutting-board)_:

- breaking; nothing.
- right_click; will convert the resource to another; (Rice Panicles -> rice; fish -> fish meat; etc)

### crafting menu

a UI menu

### plants (FLORA)

_this plants seem to reside in "Temperate Deciduous Forests"_

NOTE: not really sure that I want to make a biome and have all these plants be in it.
Would need to space them out into different biomes.

- Atropa belladonna (deadly nightshade)
- Birthwort
- white opium poppy
- Water Hemlock
- Foxglove
- Strong Scented Lettuce
- Hemlock
- Herb Paris
- Henbane

### mobs (FAUNA)

**Maybe some of the smaller mobs could be be 2D and animated**

#### hostile mobs

_spawn in dark:_

- cult members
- ghosts (not sure)
- Tooth Fairies (they want teeth, not cute)

_natural spawn:_

- boar (will become neutral when tamed)
- bears
- trolls (maybe, something huge!)

#### neutral mobs

will attack the player if provoked

- rats (not sure)
- spiders
- raccoons (could be used as early organization, as long as they get feed they will do things for the player; they do randomly take breaks)

#### passive mobs

_100%:_

- sheep
- fish

_maybe/later on:_

- squirrels
- vole (rat like, cuter)
- cows
- deer
- bugs;butterflies; firefly; bees; ants(could be cool to see a carrot moving, but its just an ant moving it); rollie pollie;fly or gnat;
- frogs; cute frogs, but also cult like
- ducks
- chickens
- raven (I think they are kinda cool)
- birds
- mushroom creatures?
