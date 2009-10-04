#--------------------------
## Tests for hack_is_non_empty_array()
#--------------------------

#--------------------------
## Ensures that hack_is_non_empty_array() outputs nothing if variable is not an
## array.
#--------------------------
function test_hack_is_non_empty_array_with_non_array() {
    local a="foo"

    assertNull "\$a is '$a' and is not an array" "$(hack_is_non_empty_array a)"
}

#--------------------------
## Ensures that hack_is_non_empty_array() outputs nothing if variable is an
## empty array.
#--------------------------
function test_hack_is_non_empty_array_with_empty_array() {
    local -a a=()
    
    assertNull "\$a is '${a[@]}' and is an empty array" "$(hack_is_non_empty_array a)"
}

#--------------------------
## Ensures that hack_is_non_empty_array() outputs nothing if variable is not
## an empty array.
#--------------------------
function test_hack_is_non_empty_array_with_nonempty_array() {
    local -a a=("foo")
    
    assertNotNull "\$a is '${a[@]}' and is not an empty array" "$(hack_is_non_empty_array a)"
}
