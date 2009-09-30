function mtest_shunit_source() {
    source $(module_get_path mtest)/shunit/current/shUnit
    if [[ -n $MODULES_DEBUG ]]; then
        source $(module_get_path mtest)/shunit/current/shUnitPlus
    else
        # workaround shUnitPlus depending on $SHUNIT_HOME
        source $(module_get_path mtest)/shunit/current/shUnitPlus >/dev/null 2>&1
    fi
}

function mtest_shunit_init() {
    if [[ -z $SHUNIT_HOME ]]; then
        SHUNIT_HOME=$(module_get_path mtest)/shunit/current
    fi    
}

function mtest_shunit() {
    local module_name=$1
    local module_path=$(module_get_path $module_name)

    if [[ ! -d $module_path/shunit ]]; then
        return 1
    fi

    if [[ -f $module_path/shunit/tests.sh ]]; then
        source $module_path/shunit/tests.sh
    fi

    source $module_path/shunit/*.sh

    shuStart
}
