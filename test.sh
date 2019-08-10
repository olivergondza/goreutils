#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export BIN="$DIR"/bin
for test in ${DIR}/test/*.t; do
  cram "$test"
done

for test in ${DIR}/test/*.sh; do
  "$test"
done
