function tpl_do() {
    tpl_copy
    tpl_configure
}

function tpl_copy() {
    for item in $tpl_src_path; do
        cp -a $item $tpl_dest_path
    done
}

function tpl_configure() {
    for item in $tpl_src_path; do
        echo $item
    done
}
