#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# The role of this module is to generate the documentation of installed modules.
# It depends on bashdoc which is provided.
# <p>
# Type "conf docs" to configure the output directory.

# Sets up the default path.
function docs_post_source() {
    export docs_path="/tmp/docs"
    export docs_template_path="$(module_get_path docs)/bwdocs/templates"
}

# Generates all the documentation. It depends on bashdoc until another bash
# documentation tool requires some abstraction.
# Note: the param will go away and module.sh and its documentation will move
# into their own module directory.
# @param   Path to the dir with module.sh and README.rst
function docs() {
    local framework_path="$1"

    $(module_get_path docs)/bwdocs/doc.pl $(module_get_repo_paths)

    rst2html "$framework_path/README.rst" > "$docs_path/README.html"
}
