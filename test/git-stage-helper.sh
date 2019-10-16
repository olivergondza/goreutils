#!/usr/bin/env bash
# https://disconnected.systems/blog/another-bash-strict-mode/
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# assrt is a tool for test, assert is a system under test
export PATH="$BIN:$BIN/../test:$PATH"

function _test() {
    export gdir="$(mktemp -d /tmp/git-stage-helper-XXXXXXXX)"
    assrt --succeeds --running git,init,${gdir}
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
    assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "nothing to commit"

    # No new files
    echo "__foo__" > file.txt
    git add file.txt
    assrt --running git,commit,-m,init --succeeds
    assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "nothing to commit"
}
_test empty

function new_file() {
    # Given
    echo "__foo__" > file.txt

    # When
    enter 'd' 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "Next file.txt.*__foo__"
    # Then
    assrt --running "git,status,--short,--porcelain" --out-matches "?? file.txt"

    # When
    enter 'a' | assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "Next file.txt"
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

    # Then
    enter 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "Next dir/"
    enter 'd' 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "__deep__"
    enter 'a' 'd' 'q' | assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "__root__"
    git restore --staged deep.txt
    enter 'a' 'a' | assrt --running "git-stage-helper" --forward-in --succeeds --out-matches "Done"
}
_test non_root_work

function merge_file() {
    # Given 2 conflicting branches
    git config --local mergetool.keepBackup true # Prevent running mergetool from messing up the workspace
    git config --local mergetool.fake.cmd "$DIR/git-stage-helper/merge-ours" # Fake conflict resolution
    git config --local merge.tool fake

    echo "foo" > file.txt
    git add file.txt
    git commit -m init > /dev/null

    git checkout -q -b conflict
    echo "bar" > file.txt
    git commit -m change1 file.txt > /dev/null
    git checkout -q -

    echo "bax" > file.txt
    git commit -m change2 file.txt > /dev/null

    # When merged
    git merge conflict > /dev/null || true # Expected to fail pointing out merge conflict

    enter 'm' 'q' | assrt --running "git-stage-helper" --forward-in --err-matches "Updated 1 path from" --out-matches "Next file.txt"
    assrt --running "git,status" --succeeds --out-matches "All conflicts fixed but you are still merging"
}
_test merge_file
