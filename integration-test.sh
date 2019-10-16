#!/usr/bin/env bash
# Inspired by https://disconnected.systems/blog/another-bash-strict-mode/
set -ueo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

targets=(
  "arch"
  "alpine"
  "centos"
  "fedora"
  "opensuse"
  "debian" #No out of the box support: gawk required
  "ubuntu" #No out of the box support: gawk required
)

function wrap_in_container() {
  target="$1"
  tag="$2"
  docker build --force-rm -t "$tag" -f "./integration-test/test-containers/${target}" ./integration-test/test-containers/
  docker run --rm --volume "${DIR}:/tmp/goreutils" "$tag" "/tmp/goreutils/test.sh"
}

total=0
function run_test() {
  target="$1"
  tag="goreutils-it-${target}"
  if wrap_in_container "$target" "$tag" 2>&1 | sed 's/^/    /'; then
    echo "SUCCESS"
  else
    echo "FAILURE"
    total=1
  fi
}

for target in "${targets[@]}"; do
  echo "=== $target ==="
  run_test "$target"
done

exit "$total"
