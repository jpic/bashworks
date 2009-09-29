#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#--------------------------
##	@Synopsis	Todo management functions
##	@Copyright	Copyright 2009, James Pic
##	@License	Apache
#--------------------------

#--------------------------
## Adds a todo to the list.
## @param Todo name
## @return 2 If the todo name param was not given.
#--------------------------
function todo_add() {
    local usage="todo_add name"
    local todo_name="$*"

    if [[ -z $todo_name ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    todo_list+=("$todo_name")

    jpic_print_info "Added: $todo_name"
}

#--------------------------
## Prints the todo list.
## @Credit Riviera#bash@irc.freenode.net
#--------------------------
function todo_list() {
    for i in ${!todo_list[*]}; do
        echo "#$i ${todo_list[$i]}"
        i=$(($i+1))
    done
}

#--------------------------
## Removes a todo from the list.
## @param Index of the todo.
#--------------------------
function todo_delete() {
    local usage="todo_delete todo_id"
    local todo_id="$1"
    local todo_name="${todo_list[$todo_id]}"

    # BUG: can't remove todo indexed "0"
    if [[ -z $todo_id ]]; then
        jpic_print_error "Usage: $usage"
        return 2
    fi

    unset todo_list[$todo_id]

    if [[ -z $todo_name ]]; then
        jpic_print_warn "#$todo_id: empty name"
    fi

    jpic_print_info "Removed #$todo_id: $todo_name"
}
