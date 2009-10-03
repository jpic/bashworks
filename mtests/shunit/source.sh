function mtests_shunit_pre_source() {
    export SHUNIT_HOME="$(module_get_path mtests_shunit)/current"
}

function mtests_shunit_source() {
    source $(module_get_path mtests_shunit)/current/shUnitPlus >/dev/null 2>&1
}

function mtests_shunit_post_source() {
    if [[ -z $SHUNIT_HOME ]]; then
        SHUNIT_HOME=$(module_get_path mtests_shunit)/current
    fi    
}

function mtests_shunit() {
    local module_name=$1
    local module_path=$(module_get_path $module_name)

    if [[ ! -d $module_path/shunit ]]; then
        return 1
    fi

    if [[ -f $module_path/shunit.sh ]]; then
        source $module_path/shunit.sh
    fi

    source $module_path/shunit/*.sh

    shuStart
}
