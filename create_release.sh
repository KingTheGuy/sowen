#!/bin/bash

dir_name=$(basename $(pwd))_$1
echo $dir_name

zip -r $dir_name.zip \
LICENSE \
LICENSE-MEDIA-CC-BY-4.0 \
README.md \
game.conf \
minetest.conf \
mods/* \
settingtypes.txt

