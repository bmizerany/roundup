#!/usr/bin/env roundup

# Explain
describe "Test edge cases that cannot throw off roundup"

before() {
    # A `cd` in `before` cannot throw off roundup.
    cd /tmp
    # Mess with $PATH
    #
    # NOTE: Ordinarily, switching on the test name isn't ideal practice;
    # we're messing with some strange edge-cases here, so I'm not to unhappy
    # about it.
    if test $roundup_test_name = "it_hath_not_path_before_thy"
    then PATH=
    fi
}

after() {
    # Try messing with the $PATH in `after`
    if test $roundup_test_name = "it_hath_path_til_after"
    then PATH=
    fi
}

it_is_in_tmp() {
    test "$(pwd)" = "/tmp"
}

it_hath_path_til_after() {
    command -v ls >/dev/null
}

it_hath_not_path_before_thy() {
    ! command -v ls >/dev/null
}
