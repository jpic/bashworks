#function GetSuiteList() {
#	local suiteList=""
#    local suite=""
#    
#    for module_path in ${module_paths[@]}; do
#        if [[ -d $module_path/tests ]]; then
#            for file in $module_path/tests/*; do
#                suiteFile=${file##*/}
#                suiteName=${suiteFile%%.*}
#                suiteList="$suiteList $suiteName"
#            done
#        fi
#    done
#
#    echo $suiteList
#}


function assert_greater_than() {
}
