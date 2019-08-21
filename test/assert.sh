#!/usr/bin/env bash

# assrt is a tool for test, assert is a system under test
export PATH="$BIN:$BIN/../test:$PATH"
export RES="./test/assert"

# Args

## Invalid
assrt --running assert,--message \
    --exit-with 1 --no-out --err-matches '^Option --message given with no value\n'

assrt --running assert,--exit-with \
    --exit-with 1 --no-out --err-matches '^Option --exit-with given with no value\n'

assrt --running assert,--out-matches \
    --exit-with 1 --no-out --err-matches '^Option --out-matches given with no value\n'

assrt --running assert,--err-matches \
    --exit-with 1 --no-out --err-matches '^Option --err-matches given with no value\n'

assrt --running assert,--running \
    --exit-with 1 --no-out --err-matches '^Option --running given with no value\n'

assrt --running assert,--message,foo \
    --exit-with 1 --no-out --err-matches '^No operation specified. Use --running\n'

assrt --running assert,--foo,--message \
    --exit-with 1 --no-out --err-matches '^Unknown option --foo given\n'

# Valid

assrt --succeeds-silently --running 'assert,--running,true,--succeeds,--no-out'
assrt --succeeds-silently --running 'assert,--running,true,--exit-with,0,--no-err,--no-out'
assrt --succeeds-silently --running 'assert,--running,true,--succeeds-silently'

assrt --succeeds-silently --running \
    'assert,--exit-with,0,--out-matches,42,--running,awk\,BEGIN {print 6*7}'

# Correctness

assrt --running 'assert,--running,true,--exit-with,1' \
    --exit-with 2 --no-out --err-matches $'^ASSERT: Failed running: \'true\'\n  - Exit code mismatch. Expected 1, was 0\n'

assrt --running 'assert,--running,false,--exit-with,0' \
    --exit-with 2 --no-out --err-matches $'^ASSERT: Failed running: \'false\'\n  - Exit code mismatch. Expected 0, was 1\n$'

assrt --running 'assert,--running,false,--succeeds-silently' \
    --exit-with 2 --no-out --err-matches $'^ASSERT: Failed running: \'false\'\n  - Exit code mismatch. Expected 0, was 1\n$'

## Output
### no-stdout/no-stderr
assrt --running 'assert,--running,seq\,1,--succeeds-silently' \
    --exit-with 2 --no-out --err-matches \
    $'ASSERT: Failed running: \'seq\' \'1\'\n  - Empty stdout expected, was:\n    1\n'

assrt --running 'assert,--running,sh\,-c\,seq 1 >&2,--succeeds-silently' \
    --exit-with 2 --no-out --err-matches \
    $'ASSERT: Failed running: \'sh\' \'-c\' \'seq 1 >&2\'\n  - Empty stderr expected, was:\n    1\n'

### stdout-equals
assrt --running 'assert,--running,printf\,foobar,--succeeds,--out-equals,foobar' --succeeds-silently
assrt --running $'assert,--running,printf\,foo,--succeeds,--out-equals,bar' \
    --exit-with 2 --no-out --err-equals-file "$RES/no-newline.stdout-mismatch"

### stderr-equals
assrt --running 'assert,--running,sh\,-c\,printf foobar >&2,--no-out,--err-equals,foobar' --succeeds-silently
assrt --running 'assert,--running,sh\,-c\,printf foobar >&2,--no-out,--err-equals,foobaz' \
    --exit-with 2 --no-out --err-equals-file "$RES/no-newline.stderr-mismatch"

### stdout-equals-file
assrt --running "assert,--running,cat\,$RES/multiline,--succeeds,--out-equals-file,$RES/multiline" --succeeds-silently
assrt --running "assert,--running,sed\,s/standard/STANDARD/\,$RES/multiline,--succeeds,--out-equals-file,$RES/multiline" \
    --exit-with 2 --no-out --err-equals-file $RES/multiline.stdout-mismatch

### stderr-equals-file
assrt --running "assert,--running,sh\,-c\,cat $RES/multiline >&2,--exit-with,0,--err-equals-file,$RES/multiline" --succeeds-silently
assrt --running "assert,--running,sh\,-c\,sed s/standard/STANDARD/ $RES/multiline >&2,--exit-with,0,--err-equals-file,$RES/multiline" \
    --exit-with 2 --no-out --err-equals-file $RES/multiline.stderr-mismatch

# Passing input with special chars as input it a major pain. All that assert expects
# is having `,` escaped (doubly here) but with shell escaping rules and trailing
# newline trimming it is better avoided using --(out|err)--equals-file
escape_execlist_delimiter=$'s/\\,/\\\\,/'
assrt --running "assert,--running,cat\,$RES/full-ascii,--out-equals,$(sed "$escape_execlist_delimiter" "$RES/full-ascii")"$'\n' --succeeds-silently
assrt --running "assert,--running,cat\,$RES/full-ascii,--out-equals-file,$RES/full-ascii" --succeeds-silently

# Environment
export ASSERT_TEST_VAR=42
assrt --running 'assert,--running,sh\,-c\,printf "$ASSERT_TEST_VAR",--succeeds,--out-matches,42' \
    --succeeds-silently

assrt --running 'assert,--running,wc\,-l' --succeeds-silently
