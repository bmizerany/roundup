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

# Prerequisits
# ------------

# Before anything, we need to know if what we're testing exists.
r5tf=roundup-5-test.sh
test -f $r5tf || {
    echo 1>&2 '! fatal:' "$r5tf does not exist in $PWD; exiting."
    exit 1
}

r5t() {
    sh $0 $r5tf
}

# The Plan
# --------

# `describe` the plan meaningfully.
describe "roundup(1) testing roundup(5)"

it_displays_the_title() {
    first_line=$(r5t | head -n 1)
    test "$first_line" "=" "roundup(5)"
}
