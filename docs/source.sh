#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
## The role of this module is to generate the documentation of installed modules.
## It depends on bashdoc which is provided.
## <p>
## Type "conf docs" to configure the output directory.
#--------------------------

#--------------------------
## Sets up the default path.
#--------------------------
function docs_post_source() {
    docs_path="/tmp/docs"
}

#--------------------------
## Generates all the documentation. It depends on bashdoc until another bash
## documentation tool requires some abstraction.
## @param   Path to the dir with module.sh and README.rst
#--------------------------
function docs() {
    local framework_path="$1"

    rst2html "$framework_path/README.rst" > "$docs_path/README.html"

    $(module_get_path docs_bashdoc)/current/bashdoc.sh \
        -p "Module.sh framework" -o "$docs_path/module.sh" "$framework_path/module.sh"

    for module_name in ${!module_paths[@]}; do
        docs_bashdoc_for_module $module_name
    done
}
