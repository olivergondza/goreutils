#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# assrt is a tool for test, assert is a system under test
export PATH="$BIN:$BIN/../test:$PATH"

# Incorrect inputs

assrt --running take --exit-with 1 --out-matches \
    'Usage: take <LENGTH> <START> \[-- <ITEMS>...\]'

assrt --running take,1 --exit-with 1 --out-matches \
    'Usage: take <LENGTH> <START> \[-- <ITEMS>...\]'

assrt --running take,foo,1 --exit-with 1 --out-matches \
    'Invalid LENGTH: foo'
assrt --running take,-1,1  --exit-with 1 --out-matches \
    'Invalid LENGTH: -1'
assrt --running take,1.1,1  --exit-with 1 --out-matches \
    'Invalid LENGTH: 1.1'

assrt --running take,1,foo --exit-with 1 --out-matches \
    'Invalid START: foo'
assrt --running take,1,-1  --exit-with 1 --out-matches \
    'Invalid START: -1'
assrt --running take,1,1.1  --exit-with 1 --out-matches \
    'Invalid START: 1.1'

# Take command arguments

assrt --running take,1,0,--,foo,bar,bax --succeeds --out-matches '^foo\n$'
assrt --running take,1,1,--,foo,bar,bax --succeeds --out-matches '^bar\n$'
assrt --running take,1,2,--,foo,bar,bax --succeeds --out-matches '^bax\n$'
assrt --running take,2,0,--,foo,bar,bax --succeeds --out-matches '^foo\nbar\n$'
assrt --running take,2,1,--,foo,bar,bax --succeeds --out-matches '^bar\nbax\n$'
assrt --running take,3,0,--,foo,bar,bax --succeeds --out-matches '^foo\nbar\nbax\n$'

# Take stdin lines

# TODO better way to provide stdin
print_stdin='sh,-c,echo -e "foo\nbar\nbax"'
assrt --running "$print_stdin | take 1 0" --succeeds --out-matches "^foo\n$"
assrt --running "$print_stdin | take 1 1" --succeeds --out-matches "^bar\n$"
assrt --running "$print_stdin | take 1 2" --succeeds --out-matches "^bax\n$"
assrt --running "$print_stdin | take 2 0" --succeeds --out-matches "^foo\nbar\n$"
assrt --running "$print_stdin | take 2 1" --succeeds --out-matches "^bar\nbax\n$"
assrt --running "$print_stdin | take 3 0" --succeeds --out-matches "^foo\nbar\nbax\n$"
