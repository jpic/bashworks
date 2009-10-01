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

testSuccess2()
{
	functionsCalled="$functionsCalled $FUNCNAME" ;
	assert true ;
}

testFailure2()
{
	functionsCalled="$functionsCalled $FUNCNAME" ;

	assert false ;
}
