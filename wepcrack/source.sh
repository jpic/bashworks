function wepcrack_pre_source() {
    mlog warn "wepcrack module not ported to module.sh yet, still using 0alpha0 template ... err ..."
    module_blacklist_add wepcrack
}
