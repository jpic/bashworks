#--------------------------
## Output something if a variable is a non empty array.
## @param Variable name
#--------------------------
function hack_is_non_empty_array() {
    declare -a | grep $1=\'\(\\[;
}

function hack_cdpath() {
    local repo_path=""

    for path in ${module_paths[*]}; do
        repo_path="${path%/*}"

        if [[ ! $CDPATH =~ "${repo_path}" ]]; then
            CDPATH+=":${repo_path}"
        fi
    done
}
