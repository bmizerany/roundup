#!/bin/sh
# [r5]: roundup.5.html
# [r1t]: roundup-1-test.sh.html
# [r5t]: roundup-5-test.sh.html
#
# _(c) 2010 Blake Mizerany - MIT License_
#
# Spray **roundup** on your shells to eliminate weeds and bugs.  If your shells
# survive **roundup**'s deathly toxic properties, they are considered
# roundup-ready.
#
# **roundup** reads shell scripts to form test plans.  Each
# test plan is sourced into a sandbox where each test is executed.
#
# See [roundup-1-test.sh.html][r1t] or [roundup-5-test.sh.html][r5t] for example
# test plans.
#
# __Install__
#
#     git clone http://github.com/bmizerany/roundup.git
#     cd roundup
#     make
#     sudo make install
#     # Alternatively, copy `roundup` wherever you like.
#
# __NOTE__:  Because test plans are sourced into roundup, roundup prefixes it's
# variable and function names with `roundup_` to avoid name collisions.  See
# "Sandbox Test Runs" below for more insight.

# Usage and Prerequisites
# -----------------------

# Exit if any following command exits with a non-zero status.
set -e

# The current version is set during `make version`.  Do not modify this line in
# anyway unless you know what you're doing.
VERSION="0.1.0"

# Usage is defined in a specific comment syntax. It is `grep`ed out of this file
# when needed (i.e. The Tomayko Method).  See
# [shocco](http://rtomayko.heroku.com/shocco) for more detail.
#/ usage: roundup [plan ...]

roundup_usage() {
    grep '^#/' <"$0" | cut -c4-
}

expr -- "$*" : ".*--help" >/dev/null && {
    roundup_usage
    exit 0
}

# Consider all scripts with names matching `*-test.sh` the plans to run unless
# otherwise specified as arguments.
if [ "$#" -gt "0" ]
then
    roundup_plans="$@"
else
    roundup_plans="$(ls *-test.sh)"
fi

# Create a temporary storage place for test output to be retrieved for display
# after failing tests.
roundup_tmp="$PWD/.roundup.$$"
rm -rf $roundup_tmp
mkdir $roundup_tmp

# __Tracing failures__
roundup_trace() {
    # Delete the first two lines that represent roundups execution of the
    # test function.  They are useless to the user.
    sed '1,2d'                                   |
    # Trim the two left most `+` signs.  They represent the depth at which
    # roundup executed the function.  They also, are useless and confusing.
    sed 's/^++//'                                |
    # Indent the output by 4 spaces to align under the test name in the
    # summary.
    sed 's/^\(.*\)$/    ! \1/'                   |
    # Highlight the last line to bring notice to where the error occurred.
    sed "\$s/\(.*\)/$mag\1$clr/"
}

# __Other helpers__

# This is used below to test if `before`, `after`, and tests are really
# functions.
roundup_isfunc() {
    [ "$(type -t "$1")" = function ] && true || false
}

# Defaults a non-function to `true`, which will execute quietly ignoring any
# arguments, otherwise the function in question is returned.
roundup_cfunc() {
    if roundup_isfunc "$1"
    then printf "$1"
    else printf "true"
    fi
}

# Track the test stats while outputting a real-time report.  This takes input on
# **stdin**.  Each input line must come in the format of:
#
#     # The plan description to be displayed
#     d <plan description>
#
#     # A passing test
#     p <test name>
#
#     # A failed test
#     f <test name>
roundup_summarize() {
    set -e

    # __Colors for output__

    # Use colors if we are writing to a tty device.
    if test -t 1
    then
        red=$(printf "\033[31m")
        grn=$(printf "\033[32m")
        mag=$(printf "\033[35m")
        clr=$(printf "\033[m")
    fi

    # Make these available to `roundup_trace`.
    export red grn mag clr

    ntests=0
    passed=0
    failed=0

    while read status name
    do
        case $status in
        p)
            ntests=$(expr $ntests + 1)
            passed=$(expr $passed + 1)
            printf "  $name: "
            printf "$grn[PASS]$clr\n"
            ;;
        f)
            ntests=$(expr $ntests + 1)
            failed=$(expr $failed + 1)
            printf "  $name: "
            printf "$red[FAIL]$clr\n"
            roundup_trace < $roundup_tmp/$name
            ;;
        d)
            printf "$name\n"
            ;;
        esac
    done
    # __Test Summary__
    #
    # Display the summary now that all tests are finished.
    printf "=======================================\n"
    printf "Tests:  %3d | " $ntests
    printf "Passed: %3d | " $passed
    printf "Failed: %3d"    $failed
    printf "\n"
}

# Sandbox Test Runs
# -----------------

# The above checks guarantee we have at least one test.  We can now move through
# each specified test plan, determine it's test plan, and administer each test
# listed in a isolated sandbox.
for roundup_p in $roundup_plans
do
    # Create a sandbox, source the test plan, run the tests, then leave
    # without a trace.
    (
        # Consider the description to be the `basename` of <plan> minus the
        # tailing -test.sh.
        roundup_desc=$(basename "$roundup_p" -test.sh)

        # Define functions for
        # [roundup(5)][r5]

        # A custom description is recommended, but optional.  Use `describe` to
        # set the description to something more meaningful.
        # TODO: reimplement this.
        describe() {
            roundup_desc="$*"
        }

        # Seek test methods and aggregate their names, forming a test plan.
        # This is done before populating the sandbox with tests to avoid odd
        # conflicts.

        # TODO:  I want to do this with sed only.  Please send a patch if you
        # know a cleaner way.
        roundup_plan=$(
            grep "^it_.*()" $roundup_p           |
            sed "s/\(it_[a-zA-Z0-9_]*\).*$/\1/g"
        )

        # We have the test plan and are in our sandbox with [roundup(5)][r5]
        # defined.  Now we source the plan to bring it's tests into scope.
        . $roundup_p

        # Output the description signal
        roundup_desc=$(printf "$roundup_desc" | tr "\n" " ")
        printf "d $roundup_desc\n"

        # Consider `before` and `after` usable if present or default them to
        # `true` if not.
        roundup_before=$(roundup_cfunc before)
        roundup_after=$(roundup_cfunc after)

        for roundup_test_name in $roundup_plan
        do
            # Avoid executing a non-function by checking the name we have is, in
            # fact, a function.
            if roundup_isfunc $roundup_test_name
            then
                # If before wasn't defined, then this is `true`.
                $roundup_before

                # Momentarily turn of auto-fail to give us access to the tests
                # exit status in `$?` for capturing.
                set +e
                (
                    # Set `-xe` before the `eval` in the subshell.  We want the test
                    # to fail fast to allow for more accurate output of where things
                    # went wrong but not in _our_ process because a failed test
                    # should not immediately fail roundup.  Each tests trace output
                    # is saved in temporary storage.
                    set -xe
                    eval "$roundup_test_name"
                ) >$roundup_tmp/$roundup_test_name 2>&1

                # We need capture the exit status before returning the set -e
                # mode.  Returning with `set -e` before we capture the exit
                # status will result in `$?` being set with `set`'s status
                # instead.
                roundup_result=$?

                # It's safe to return to normal operation.
                set -e

                # If `after` wasn't defined, then this is `true`.
                $roundup_after

                # This is the final step of a test.  Print it's pass/fail signal
                # and name 
                if [ "$roundup_result" -ne 0 ]
                then printf "f"
                else printf "p"
                fi

                printf " $roundup_test_name\n"
            fi
        done
    )
done |

# All signals are piped to this for summary.
roundup_summarize
