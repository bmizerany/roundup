#!/usr/bin/env roundup
#
# This Will Fail
# --------------
#
# The before function 
describe "roundup before trace"

# This `before` function is run before it_works. The `false` will simulate
# an error. Hence, `it_works` should not be called at all, but it should be
# marked as failed and the `before` trace should be displayed.
before () {
	false
}

# A trivial and correct test case. But because `before` is broken, this 
# testcase will fail as well.
it_works () {
	true
}
