#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# The role of this module is to generate the documentation of installed modules.
# It depends on bashdoc which is provided.
# <p>
# Type "conf docs" to configure the output directory.

# Sets up the default path.
function docs_post_source() {
    docs_path="/tmp/docs"
    docs_template_path="$(module_get_path docs)/bwdocs/templates"
    docs_template_debug=0
    docs_debug=0
}

# Generates all the documentation. It depends on bashdoc until another bash
# documentation tool requires some abstraction.
function docs() {
    if [[ ! -d "$docs_path" ]]; then
        mkdir -p "$docs_path"
        mlog info "Created $docs_path"
    else
        rm -rf "$docs_path/*"
        mlog info "Cleaned $docs_path"
    fi

    export docs_path
    export docs_template_path
    $(module_get_path docs)/bwdocs/doc.pl $(module_get_repo_paths)

    rst2html "$(module_get_path module)/docs/guide.rst" > "$docs_path/bashworks_guide.html"
}

function docs_test() {
    docs_path="$(module_get_path docs)/bwdocs/example/"
    if [[ ! -d "$docs_path" ]]; then
        mkdir -p "$docs_path"
        mlog info "Created $docs_path"
    else
        rm -rf "$docs_path/*"
        mlog info "Cleaned $docs_path"
    fi

    export docs_path
    export docs_template_path
    export docs_template_debug
    export docs_debug
    $(module_get_path docs)/bwdocs/doc.pl $(module_get_path docs)/bwdocs
}
