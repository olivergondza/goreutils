#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

export PATH="$BIN:$PATH"

# Args

## Invalid
[ "$(assert --message        2>&1)" == "Option --message given with no value" ]
[ "$(assert --exit-with      2>&1)" == "Option --exit-with given with no value" ]
[ "$(assert --stdout-matches 2>&1)" == "Option --stdout-matches given with no value" ]
[ "$(assert --stderr-matches 2>&1)" == "Option --stderr-matches given with no value" ]
[ "$(assert --running        2>&1)" == "Option --running given with no value" ]

[ "$(assert 2>&1)" == "No operation specified. Use --running" ]

# Valid

assert --running true --succeeds --no-stderr --no-stdout
assert --running true --exit-with 0 --no-stderr --no-stdout
assert --running true --succeeds-silently

assert --exit-with 0 --stdout-matches "42" \
    --running ansible,-a,'awk "BEGIN {print 6*7}"',localhost

assert --succeeds --stdout-matches "42" \
    --running ansible,-a,"awk 'BEGIN {print 6*7}'",localhost

# Correctness

## Exit
[ "$(assert --running true  --exit-with 1       2>&1)" == "ASSERT: Exit code mismatch. Expected 1, was 0" ]
[ "$(assert --running false --exit-with 0       2>&1)" == "ASSERT: Exit code mismatch. Expected 0, was 1" ]
[ "$(assert --running false --succeeds-silently 2>&1)" == "ASSERT: Exit code mismatch. Expected 0, was 1" ]

## Outputs
[ "$(assert --running seq,1 --succeeds-silently 2>&1 || true)" == $'ASSERT: Standard output mismatch. Expected text matching \'^$\', was:\n1\nASSERT: ===' ]
[ "$(assert --running 'sh,-c,seq 1 >&2' --succeeds-silently 2>&1 || true)" == $'ASSERT: Standard error mismatch. Expected text matching \'^$\', was:\n1\nASSERT: ===' ]

# Environment
export ASSERT_TEST_VAR=42
assert --running sh,-c,'printf $ASSERT_TEST_VAR' --succeeds --no-stderr --stdout-matches "^42$"
