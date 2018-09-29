# https://bitbucket.org/brodie/cram
Incorrect inputs

  $ $BIN/take 2>&1
  Usage: take <LENGTH> <START> [-- <ITEMS>...]
  [1]

  $ $BIN/take 1 2>&1
  Usage: take <LENGTH> <START> [-- <ITEMS>...]
  [1]

  $ $BIN/take foo 1 2>&1
  Invalid LENGTH: foo
  [1]
  $ $BIN/take -1 1 2>&1
  Invalid LENGTH: -1
  [1]
  $ $BIN/take 1.1 1 2>&1
  Invalid LENGTH: 1.1
  [1]

  $ $BIN/take 1 foo 2>&1
  Invalid START: foo
  [1]
  $ $BIN/take 1 -1 2>&1
  Invalid START: -1
  [1]
  $ $BIN/take 1 1.1 2>&1
  Invalid START: 1.1
  [1]

Take command arguments

  $ $BIN/take 1 0 -- foo bar bax
  foo
  $ $BIN/take 1 1 -- foo bar bax
  bar
  $ $BIN/take 1 2 -- foo bar bax
  bax
  $ $BIN/take 2 0 -- foo bar bax
  foo
  bar
  $ $BIN/take 2 1 -- foo bar bax
  bar
  bax
  $ $BIN/take 3 0 -- foo bar bax
  foo
  bar
  bax

Take stdin lines

  $ echo -e "foo\nbar\nbax" | $BIN/take 1 0
  foo

  $ echo -e "foo\nbar\nbax" | $BIN/take 1 1
  bar

  $ echo -e "foo\nbar\nbax" | $BIN/take 1 2
  bax

  $ echo -e "foo\nbar\nbax" | $BIN/take 2 0
  foo
  bar

  $ echo -e "foo\nbar\nbax" | $BIN/take 2 1
  bar
  bax

  $ echo -e "foo\nbar\nbax" | $BIN/take 3 0
  foo
  bar
  bax
