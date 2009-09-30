#!/bin/bash
# /***************************************************************************
#  *                                                                         *
#  *   This program is free software; you can redistribute it and/or modify  *
#  *   it under the terms of the GNU Lesser General Public License as        *
#  *   published by  the Free Software Foundation; either version 2 of the   *
#  *   License, or (at your option) any later version.                       *
#  *                                                                         *
#  *   (C) 2002-2003 Dakshinamurthy K (kd@subexgroup.com)                    *
#  ***************************************************************************/

testAssertSuccess()
{
	assert true
	assert_message 'This will succeed' true
	assert_fail false
	assert_fail_message 'This will succeed' false
	assert_pass true
	assert_pass_message 'This will succeed' true
	assert_exitcode 0 true
	assert_exitcode_message 'This will succeed' 0 true
	messageActual='No assertions failed'
}

testAssertMessage()
{
	assert_message 'testAssertMessage failed' false
}

testAssertFailMessage()
{
	assert_fail_message 'testAssertFailMessage failed' true
}

testAssertPassMessage()
{
	assert_pass_message 'testAssertPassMessage failed' false
}

testAssertExitCodeMessage()
{
	assert_exitcode_message 'testAssertExitCodeMessage failed' 0 false
}
