#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -euo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

status=0
export BIN="$DIR"/bin
for test in ${DIR}/test/*.sh; do
  echo "$test"
  cd "$DIR"

  # Print everything to stderr and fail if there is 'ASSERT:'
  if ! "$test" 2>&1 | awk "BEFORE {error=0}; //; /ASSERT:/ { error=1 }; END {exit error}" >&2; then
    status=1
  fi
done

exit "$status"
