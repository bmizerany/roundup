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

# Test basic success and failure conditions.  These are intentionally _silly_
# tests to keep their results deterministic.  `it_fails` **will** fail, causing the
# whole plan to fail.
#
# __NOTE__:  the results of these, and all of the following tests are checked in
# [roundup-1-test.sh][r1t]
it_passes() {
    true
}

it_fails() {
    false
}

# Check `$foo` to ensure `before` ran.
it_runs_before() {
    test "$foo" "=" "bar"
}

# Start the `after` test.  Drop a file and check it really exists.  The sister
# test checks if `after` cleans it up.
it_runs_after_a_test_passes_part_1() {
    touch foo.txt
    test -f foo.txt
}

# Test the file dropped above is no longer on disk.  If it doesn't exist, we
# know `after` ran.
it_runs_after_a_test_passes_part_2() {
    test "!" -f foo.txt
}

# We want `after` to run if a test passes or fails.  Leaving behind debris isn't
# good practice.  This test will drop a file to disk then intentionally fail.
# It's sister test makes sure the file no longer exists, proving `after` ran.
it_runs_after_if_a_test_fails_part_1() {
    touch foo.txt
    test -f foo.txt
    false
}

# Start the `after` test.  Drop a file and check it really exists.  The sister
# test checks if `after` cleans it up.
it_runs_after_if_a_test_fails_part_2() {
    test "!" -f foo.txt
}

# Output the correct return code of a failing command of a testcase.
it_outputs_the_return_code_7() {
    function f() { return 42; }
    x=$(echo asdf)

    function g() { return 7; }
    g
}

# Roundup will ignore tests starting with `x`.  Ignored tests are still
# enumerated in the plans output marked with `[I]`.  If roundup does not ignore
# this, result in failure.
xit_ignores_this() {
    false
}
