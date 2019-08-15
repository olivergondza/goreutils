#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# assrt is a tool for test, assert is a system under test
export PATH="$BIN:$BIN/../test:$PATH"
export RES="$BIN/../test/assert"

# Args

## Invalid
assrt --running assert,--message \
    --exit-with 1 --no-stdout --stderr-matches '^Option --message given with no value\n'

assrt --running assert,--exit-with \
    --exit-with 1 --no-stdout --stderr-matches '^Option --exit-with given with no value\n'

assrt --running assert,--stdout-matches \
    --exit-with 1 --no-stdout --stderr-matches '^Option --stdout-matches given with no value\n'

assrt --running assert,--stderr-matches \
    --exit-with 1 --no-stdout --stderr-matches '^Option --stderr-matches given with no value\n'

assrt --running assert,--running \
    --exit-with 1 --no-stdout --stderr-matches '^Option --running given with no value\n'

assrt --running assert,--message,foo \
    --exit-with 1 --no-stdout --stderr-matches '^No operation specified. Use --running\n'

assrt --running assert,--foo,--message \
    --exit-with 1 --no-stdout --stderr-matches '^Unknown option --foo given\n'

# Valid

assrt --succeeds-silently --running 'assert,--running,true,--succeeds,--no-stdout'
assrt --succeeds-silently --running 'assert,--running,true,--exit-with,0,--no-stderr,--no-stdout'
assrt --succeeds-silently --running 'assert,--running,true,--succeeds-silently'

assrt --succeeds-silently --running \
    'assert,--exit-with,0,--stdout-matches,42,--running,ansible\,-a\,awk "BEGIN {print 6*7}"\,localhost'

# Correctness

assrt --running 'assert,--running,true,--exit-with,1' \
    --exit-with 2 --no-stdout --stderr-matches $'^ASSERT: Failed running: \'true\'\n  - Exit code mismatch. Expected 1, was 0\n'

assrt --running 'assert,--running,false,--exit-with,0' \
    --exit-with 2 --no-stdout --stderr-matches $'^ASSERT: Failed running: \'false\'\n  - Exit code mismatch. Expected 0, was 1\n$'

assrt --running 'assert,--running,false,--succeeds-silently' \
    --exit-with 2 --no-stdout --stderr-matches $'^ASSERT: Failed running: \'false\'\n  - Exit code mismatch. Expected 0, was 1\n$'

## Output
### no-stdout/no-stderr
assrt --running 'assert,--running,seq\,1,--succeeds-silently' \
    --exit-with 2 --no-stdout --stderr-matches \
    $'ASSERT: Failed running: \'seq\' \'1\'\n  - Expected stdout matching \'\^\$\', was:\n    1\n'

assrt --running 'assert,--running,sh\,-c\,seq 1 >&2,--succeeds-silently' \
    --exit-with 2 --no-stdout --stderr-matches \
    $'ASSERT: Failed running: \'sh\' \'-c\' \'seq 1 >&2\'\n  - Expected stderr matching \'\^\$\', was:\n    1\n'

### stdout-equals
assrt --running 'assert,--running,printf\,foobar,--succeeds,--stdout-equals,foobar' --succeeds-silently
assrt --running 'assert,--running,printf\,foo,--succeeds,--stdout-equals,bar' --exit-with 2 --no-stdout --stderr-matches \
    $'ASSERT: Failed running: \'printf\' \'foo\'\n  - Expected stdout: \'bar\', was:\n    foo'

### stderr-equals
assrt --running 'assert,--running,sh\,-c\,printf foobar >&2,--no-stdout,--stderr-equals,foobar' --succeeds-silently
assrt --running 'assert,--running,sh\,-c\,printf foobar >&2,--no-stdout,--stderr-equals,foobaz' --exit-with 2 --no-stdout \
    --stderr-matches $'ASSERT: Failed running: \'sh\' \'-c\' \'printf foobar >&2\'\n  - Expected stderr: \'foobaz\', was:\n    foobar'

### stdout-equals-file
assrt --running "assert,--running,cat\,$RES/multiline,--succeeds,--stdout-equals-file,$RES/multiline" --succeeds-silently
assrt --running "assert,--running,cat\,-n\,$RES/multiline,--succeeds,--stdout-equals-file,$RES/multiline" --exit-with 2 --no-stdout \
    --stderr-matches '3\s+ever'

### stderr-equals-file
assrt --running "assert,--running,sh\,-c\,cat $RES/multiline >&2,--exit-with,0,--stderr-equals-file,$RES/multiline" --succeeds-silently
assrt --running "assert,--running,sh\,-c\,cat -n $RES/multiline >&2,--succeeds,--stderr-equals-file,$RES/multiline" --exit-with 2 --no-stdout \
    --stderr-matches '3\s+ever'

# Environment
export ASSERT_TEST_VAR=42
assrt --running 'assert,--running,sh\,-c\,printf "$ASSERT_TEST_VAR",--succeeds,--stdout-matches,42' \
    --succeeds-silently

assrt --running 'assert,--running,wc\,-l' --succeeds-silently
