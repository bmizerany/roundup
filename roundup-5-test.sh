#!/usr/bin/env roundup
#
# This Will Fail
# --------------
#
# [r1]: #
# [r1t]: roundup-1-test.html
# [r5t]: roundup-5-test.html
# [r5]: roundup.5.html
# [sh]: http://rtomayko.github.com/shocco
#
# That is the point. This is testing [roundup(5)][r5]. A few tests fail on
# purpose, because each is testing a specific success or failure condition.
# [roundup(1)][r1] will flunk a plan executed with one or more failing tests.
# Therefore, this will fail.

# A quick note
# ------------
#
# For more information on how roundup views a test-plan, see [roundup(5)][r5].

# Let's get started
# -----------------

# `describe` the plan meaningfully.
describe "roundup(5)"

# `before` each test, set an arbitrary variable to an arbitrary value.  A later
# test checks the variable to know if `before` was run.
before() {
    foo="bar"
}

# `after` each test, delete `foo.txt` if it exists.  A later test will touch
# said file.  It's sister test will later run to check it no longer exists to
# ensure this ran.
after() {
    rm -f foo.txt
}

# Test basic success and failure conditions.  These are intentially _silly_
# tests to keep their results determinstic.  `it_fails` **will** fail, causing the
# whole plan to fail.
#
# __NOTE__:  the results of these, and all of the following tests are checked in
# [roundup-1-test.sh][r1t]
it_passes() {
    test 1 -eq 1
}

it_fails() {
    test 1 -eq 0
}

# Check `$foo` to ensure `before` ran.
it_runs_before() {
    test "$foo" "=" "bar"
}

# Start the `after` test.  Drop a file and check it really exists.  The sister
# test will check the `rm -f` in `after` ran by testing it no longer exists.
it_runs_after_part_1() {
    touch foo.txt
    test -f foo.txt
}

# Test the file dropped above is no longer on disk.  If it doesn't exist, we
# know `after` ran.
it_runs_after_part_2() {
    test "!" -f foo.txt
}

# Roundup will ignore tests starting with `x`.  Ignored tests are still
# enumerated in the plans output marked with `[I]`.  If roundup does not ignore
# this, result in failure.
xit_ignores_this() {
    it_fails
}
