#!/bin/bash
# -*- coding utf8 -*-
# @license some custom license
# @author some custom author
# @something whatever
# This is a paragraph with code after it:
##  # this is a code comment
##  this is code
# To use 80 char wide terminals multi lign
# paragraphs are supported. Look at this list:
# - this is a list item
# - this is a list item with a function link foofunc()
# References to functions like foofunc() require at least the ( suffix.
# This is a multi phrase paragraph. A list of the possible work decorations
# will be presented right now:
# - an *emphatized* word,
# - This is a multilign
#   item.
# - This is
#   another multilign
#   item.
# Link to another another file like example.sh or from another module like
# foomodule/source.sh or other_source.sh
# Reference to the $foo, $foobar and $bar variables need the dollar prefix.

# This is a typed variable comment block
declare -a foo=("bar")

# Other example, foobar
declare foobar="test"

# bar variable block
bar="foo"

# bar variable block
# @type string
typedbar=$(echo foo)

# this is a function level comment block
# @custom a custom tag
# @log something may be logged
# @see see how an @log tag reversed the call to mlog()?
function foofunc() {
    echo "foo"
    
    mlog info "This string should be used for the automagic @log tag"
}
