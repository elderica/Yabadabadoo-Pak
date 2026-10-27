#!/bin/sh
# upstream-version.sh <tag>
# Prints an upstream release tag as the three numbers that start the pak's version
# (v0.3 -> 0.3.0, v0.2.1 -> 0.2.1). Fails for anything else, such as a beta (v0.4-beta.1).
[ $# -eq 1 ] || { echo "usage: $0 <tag>" >&2; exit 2; }
echo "${1#v}" | awk -F. '
	NF > 3 { exit 1 }
	{ for (i = 1; i <= NF; i++) if ($i !~ /^[0-9]+$/) exit 1 }
	{ printf "%s.%s.%s\n", $1, (NF > 1 ? $2 : 0), (NF > 2 ? $3 : 0) }'
