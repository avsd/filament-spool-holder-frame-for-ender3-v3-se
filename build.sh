#!/usr/bin/env bash
openscad-nightly -o spool-holder.stl spool-holder.scad

openscad-nightly -D withPins=1 -o spool-holder-with-pins.stl spool-holder.scad
openscad-nightly -D onlyPins=1 -o pins.stl spool-holder.scad

openscad-nightly -D withPins=1 -D elevation=50 -o elevated-spool-holder-with-pins.stl spool-holder.scad
openscad-nightly -D onlyPins=1 -D elevation=50 -o elevated-pins.stl spool-holder.scad
