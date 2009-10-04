#--------------------------
## Various bash hacks.
#--------------------------

#--------------------------
## Check if a variable is a non empty array.
## @stdout  "Yes" if the variable is a non empty array.
## @param   Variable name
#--------------------------
function hack_is_non_empty_array() {
    declare -a | grep -q $1=\'\(\\[;

    if [[ $? == 0 ]]; then
        echo "Yes"
    fi
}

#--------------------------
## Adds each repository path to CDPATH environment variable.
## <pre>
## # change directory to somemodule, whatever is the current directory
## cd somemodule
## @variable    CDPATH, repo_path
#--------------------------
function hack_cdpath() {
    local repo_path=""

    for path in ${module_paths[*]}; do
        repo_path="${path%/*}"

        if [[ ! $CDPATH =~ "${repo_path}" ]]; then
            export CDPATH+=":${repo_path}"
        fi
    done
}
