function mtest_shunit2() {
    local module_name=$1
    local module_path=$(module_get_path $module_name)

    if [[ ! -d $module_path/shunit2 ]]; then
        return 1
    fi

    if [[ -f $module_path/shunit2.sh ]]; then
        source $module_path/shunit2.sh
    fi

    source $module_path/shunit2/suite.sh
}
