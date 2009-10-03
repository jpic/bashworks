function conf_auto_source() {
    source $(module_get_path conf_auto)/functions.sh
    source $(module_get_path conf_auto)/conf.sh
}

function conf_auto_post_source() {
    conf_auto_conf_path="$HOME/.conf_auto"

    conf_load conf_auto
}
