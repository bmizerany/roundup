#!/usr/bin/env roundup
#
# This Will Pass
# --------------
#
# [r1]: #
# [r1t]: roundup-1-test.html
# [r5t]: roundup-5-test.html
# [r5]: roundup.5.html
# [sh]: http://rtomayko.github.com/shocco
#
# This test checks **roundup** runs [roundup-5-test.sh][r5t] and fails with the
# expected output.

# A quick note
# ------------
#
# For more information on how roundup views a test-plan, see [roundup(5)][r5] or
# the [roundup(5) test][r5t].

# Let's get started
# -----------------

# Helpers
# ------------

# Prevent carpel tunnel
rup() { /bin/sh $0 $1-test.sh ; }

# The Plan
# --------

# `describe` the plan meaningfully.
describe "roundup(1) testing roundup(5)"

it_displays_the_title() {
    first_line=$(rup roundup-5 | head -n 1)
    test "$first_line" "=" "roundup(5)"
}

it_exits_non_zero() {
    status=$(set +e ; rup roundup-5 >/dev/null ; echo $?)
    test 2 -eq $status
}

it_survives_edge_cases() {
    rup edge
}
