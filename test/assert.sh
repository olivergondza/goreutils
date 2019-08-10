#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Args
## Valid

${BIN}/assert --succeeds
${BIN}/assert --no-stdout
${BIN}/assert --no-stderr

## Invalid
[ "$(${BIN}/assert --message        2>&1)" == "Option --message given with no value" ]
[ "$(${BIN}/assert --exit-with      2>&1)" == "Option --exit-with given with no value" ]
[ "$(${BIN}/assert --stdout-matches 2>&1)" == "Option --stdout-matches given with no value" ]
[ "$(${BIN}/assert --stderr-matches 2>&1)" == "Option --stderr-matches given with no value" ]

# Valid

${BIN}/assert --exit-with 0 --no-stderr --stdout-matches "42" \
    --that ansible -a 'awk "BEGIN {print 6*7}"' localhost

${BIN}/assert --succeeds --stdout-matches "42" \
    --that ansible -a "awk 'BEGIN {print 6*7}'" localhost
