function assert_break_request_first_granted() {
	__bashunit_g_testMessage="Break was expected to be the first requested"
    
    out=$(break_request)
    echo ASSERT OUT $out
    echo $out | grep -i first

	if test $? != 0 ; then
		kill -USR1 $$
	fi

    return $?
}

function assert_break_request_denied() {
	__bashunit_g_testMessage="Break was expected to be denied"
    
    out=$(break_request)
    echo ASSERT OUT $out
    echo $out | grep -i denied

	if test $? != 0 ; then
		kill -USR1 $$
	fi

    return $?
}

function assert_break_request_granted() {
	__bashunit_g_testMessage="Break was expected to be granted"
    
    out=$(break_request)
    echo ASSERT OUT $out
    echo $out | grep -i granted

	if test $? != 0 ; then
		kill -USR1 $$
	fi

    return $?
}
