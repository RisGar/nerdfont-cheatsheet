#!/usr/bin/env bash
# Script to parse i_*.sh files from https://github.com/ryanoasis/nerd-fonts/tree/master/bin/scripts/lib into csv with symbol and name

sd="$(
  cd -- "$(dirname "${0}")" >/dev/null 2>&1 || exit
  pwd -P
)"

source "${sd}/i_all.sh"

{
  printf "glyph,name\n"

  for glyph in ${!i_*}; do
    printf "%s,%s\n" "${!glyph}" "${glyph}"
  done
} >"${sd}/glyphs.csv"
