# /***************************************************************************
#  *                                                                         *
#  *   This program is free software; you can redistribute it and/or modify  *
#  *   it under the terms of the GNU Lesser General Public License as        *
#  *   published by  the Free Software Foundation; either version 2 of the   *
#  *   License, or (at your option) any later version.                       *
#  *                                                                         *
#  *   (C) 2002-2003 Dakshinamurthy K (kd@subexgroup.com)                    *
#  ***************************************************************************/
check: bashunit_impl bashunit_ut bashunit_ut_paramtypes bashunit_ut_names
	./bashunit_ut_assertions
	./bashunit_ut_names
	./bashunit_ut_paramtypes
	./bashunit_ut
	./resultcollector_ut

example: bashunit
	./bashunit BashunitTest1.sh BashunitTest2.sh BashunitTest3.sh

install: bashunit bashunit_impl resultcollector README
	install bashunit /home/jpic/bin/bashunit
	install bashunit_impl /home/jpic/bin/bashunit_impl
	install resultcollector /home/jpic/bin/resultcollector
	install -d /home/jpic/share/doc/bashunit
	install README /home/jpic/share/doc/bashunit/README
