#!/usr/bin/env bash
# Inspired by https://disconnected.systems/blog/another-bash-strict-mode/
#set -uo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

targets=(
  "arch"
  "alpine"
  "centos"
  "fedora"
  "opensuse"
  #"debian" MAWK
  #"ubuntu" MAWK
)

function run_test() {
  target="$1"
  tag="goreutils-it-${target}"
  docker build --force-rm -t "$tag" -f "./integration-test/test-containers/${target}" ./integration-test/test-containers/
  docker run --rm --volume "${DIR}:/tmp/goreutils" "$tag" "/tmp/goreutils/test.sh"
  if [ "$?" == 0 ]; then
    echo "SUCCESS"
  else
    echo "FAILURE"
  fi
}

for target in "${targets[@]}"; do
  echo "=== $target ==="
  run_test "$target" 2>&1 | sed 's/^/    /'
done
