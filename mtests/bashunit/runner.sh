#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#	@Synopsis	Break management module
#	@Copyright	Copyright 2009, James Pic
#	@License	Apache
# This script contains bashunit outputter and listener functions.
#
# Bashunit uses listener functions which names are present in the
# BASHUNIT_TESTLISTENERS environment variable, separated by spaces.
# Listener functions are run when tests are executed.
# 
# Bashunit uses outputter functions which names are present in the
# BASHUNIT_OUTPUTTER environment variable, separated by spaces.
# Outputter funcitons are run when all tests are done executing.

# Outputs a green dot when a test passes and a red F when a test fails.
# @Param   String: EndSuccess or EndFailure
TextDotListener()
{
    case $1 in
		EndSuccess)
			echo -n "${GOOD}.${NORMAL}"
			;;
		EndFailure)
			echo -n "${BAD}F${NORMAL}"
			;;
	esac
}

# Outputs the number of failed tests in red if there are any as well as
# the file name and line number of failing assertions.
TextOutputter()
{
	local failed=`ResultCollector GetFailure`
	local run=`ResultCollector GetRun`
	local success=`ResultCollector GetSuccess`
	if test $failed != 0; then
		echo "${BAD}FAILURES!!!${NORMAL}"
	fi

    if test -n $failed; then
        failed="${GOOD}${failed}${NORMAL}"
    fi

	echo "Runs = $run Success = $success Failures = $failed"
	if test $failed == 0; then
		return
	fi
	local failureList=`ResultCollector GetFailures`
	local test
	for test in $failureList; do
		echo "`$test failedFileName`:`$test failedLineNumber`: `$test failedTest` (`$test failedMessage`)"
	done
}
