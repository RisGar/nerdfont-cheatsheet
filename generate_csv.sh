#!/usr/bin/env bash
sd="$(
  cd -- "$(dirname "${0}")" >/dev/null 2>&1 || exit
  pwd -P
)"

rm "${sd}/priv/glyphs.csv"

# shellcheck disable=SC1091 # Do not pull in the sourced file
source "${sd}/glyphs/i_all.sh"

{
  printf "glyph,name\n"

  for glyph in ${!i_*}; do
    printf "%s,%s\n" "${!glyph}" "${glyph}"
  done
} >"${sd}/priv/glyphs.csv"

echo " successfully generated glyphs.csv"
