#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# assrt is a tool for test, assert is a system under test
export PATH="$BIN:$BIN/../test:$PATH"

function _test() {
    export gdir="$(mktemp -d /tmp/git-stage-helper-XXXXXXXX)"
    assrt --succeeds --no-err --running git,init,${gdir}
    pushd "${gdir}" > /dev/null

    if ! "$1"; then # Run test method
      echo "FAILED $1; state kept in $gdir"
    else
      rm -rf $gdir
    fi

    popd > /dev/null
}

function enter() {
    for key in "$@"; do
        echo "$key"
    done
}

function empty() {
    # No files and no commit
    assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "nothing to commit"

    # No new files
    echo "__foo__" > file.txt
    git add file.txt
    assrt --running git,commit,-m,init --succeeds --no-err
    assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "nothing to commit"
}
_test empty

function new_file() {
    # Given
    echo "__foo__" > file.txt

    # When
    enter 'd' 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "Next file.txt.*__foo__"
    # Then
    assrt --running "git,status,--short,--porcelain" --out-matches "?? file.txt"

    # When
    enter 'a' | assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "Next file.txt"
    # Then
    assrt --running "git,status,--short,--porcelain" --out-matches "A  file.txt"
}
_test new_file

function non_root_work() {
    # Given
    git commit -m init --allow-empty > /dev/null
    mkdir -p dir
    echo "__root__" > root.txt
    echo "__deep__" > dir/deep.txt

    # When
    cd dir
    enter 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "Next dir/"
    enter 'd' 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "+__deep__"
    enter 'a' 'd' 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "+__root__"
    git restore --staged deep.txt
    enter 'a' 'a' | assrt --running "git-stage-helper" --forward-in --succeeds --no-err --out-matches "Done"
}
_test non_root_work
