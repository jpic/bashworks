#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# Bashunit is a good script, but the assertion functions are very hard
# to use because they are not documented, and examples are like "assert true"
# <p>
# This script provides functions for bashunit which are easier to use
# not only because they are documented, but also because working and
# challenging examples are provided.

# Asserts that a command returns a zero status.
# <p>
# For example:
# <pre>
# assert_zero "ls foobar" # fails if foobar does not exist
# assert_zero ls # passes if the working directory exists
# </pre>
# @param  Command and arguments to test
function mtests_bashunit_assert_zero() {
	__bashunit_g_testMessage="Assert that $* returns 0 failed"
    
    $*

    if [[ $? != 0 ]]; then
		kill -USR1 $$
    fi
}

# Asserts that a mathematical expression is true.
# <p>
# For example:
# <pre>
# assert_math "1 > 2" # fails
# assert_math "1 == 1" # passes
# </pre>
# Refer to Bash manual section "ARITHMETIC EVALUATION" for more information.
# @param  Arithmetic expression to evaluate.
function mtests_bashunit_assert_math() {
	__bashunit_g_testMessage="Assert that $1 failed"
    eval "(( $1 ))"

    if [[ $? != 0 ]]; then
		kill -USR1 $$
    fi
}

# Asserts that an expression returns 0.
# <p>
# For example:
# <pre>
# assert_true "foobar =~ oob" # pass, "oob" is in "foobar"
# assert_true "foo == bar" # fails, "foo" is different from "bar".
# </pre>
# Refer to Bash manual section "SHELL GRAMMAR" subsection "Compound Commands".
# @param   Expression to evaluate.
function mtests_bashunit_assert_true() {
	__bashunit_g_testMessage="Assert that $1 is true failed"

    eval "[[ $1 ]]"

    if [[ $? != 0 ]]; then
		kill -USR1 $$
    fi
}
