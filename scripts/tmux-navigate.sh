#!/usr/bin/env bash

vim_navigation_timeout=0.05 # number of seconds we give Vim to navigate

direction="$1"
pane_id="$2"

get_pane_title() {
    tmux display -pt"$pane_id" -F "#{q:pane_title}"
}


pane_title="$(get_pane_title)";
pane_current_command="$(tmux display -pt"$pane_id" -F "#{q:pane_current_command}")";

pane_pos_info_str="$(tmux display -p -t"$pane_id" -F "#{pane_at_left} #{pane_at_bottom} #{pane_at_top} #{pane_at_right}")"
IFS=" " read -r -a pane_pos_info <<< "$pane_pos_info_str"

pane_at_left() { test "${pane_pos_info[0]}" -eq 1; }
pane_at_bottom() { test "${pane_pos_info[1]}" -eq 1; }
pane_at_top() { test "${pane_pos_info[2]}" -eq 1; }
pane_at_right() { test "${pane_pos_info[3]}" -eq 1; }

pane_is_zoomed() {
    test "$(tmux display -pt"$pane_id" -F "#{window_zoomed_flag}")" -eq 1;
};

command_is_vim() {
    case "${1%% *}" in
        vi|?vi|vim*|?vim*|view|?view|vi??* )
            true 
            ;;
        *) 
            false 
            ;;
    esac
}

pane_title_changed() {
    test "$pane_title" != "$(get_pane_title)" 
};

pane_contains_vim() {
    case "$pane_current_command" in
        git|*sh) command_is_vim "$pane_title" ;;
        *) 
            command_is_vim "$pane_current_command" ;;
    esac;
};

pane_contains_neovim_terminal() {
    case "$pane_title" in
        nvim?term://*) true ;;
        *) false ;;
    esac;
};

pane_contains_ssh() {
    case "$pane_current_command" in
        ssh|mosh-client) true ;;
        *) false ;;
    esac;
}

navigate() {
    direction="$1"
    # direction=$3;
    tmux_navigation_command_base="tmux select-pane"
    tmux_remote_navigation_command_base="tmux send-keys"
    vim_navigation_command_base="tmux send-keys"
    case "$direction" in
        left)
            tmux_navigation_command="$tmux_navigation_command_base -L";
            vim_navigation_command="$vim_navigation_command_base C-w h";
            tmux_remote_navigation_command="$vim_navigation_command_base C-a h";
            ;;
        bottom|down)
            tmux_navigation_command="$tmux_navigation_command_base -D";
            vim_navigation_command="$vim_navigation_command_base C-w j";
            tmux_remote_navigation_command="$vim_navigation_command_base C-a j";
            ;;
        top|up)
            tmux_navigation_command="$tmux_navigation_command_base -U";
            vim_navigation_command="$vim_navigation_command_base C-w k";
            tmux_remote_navigation_command="$vim_navigation_command_base C-a k";
            ;;
        right)
            tmux_navigation_command="$tmux_navigation_command_base -R";
            vim_navigation_command="$vim_navigation_command_base C-w l";
            tmux_remote_navigation_command="$vim_navigation_command_base C-a l";
            ;;
    esac
    if pane_contains_vim; then
        if pane_contains_neovim_terminal; then
            tmux send-keys C-\\ C-n;
        fi;
        eval "$vim_navigation_command";
        if ! pane_is_zoomed; then
            sleep $vim_navigation_timeout; # wait for Vim to change title;
            if ! pane_title_changed; then
                tmux send-keys BSpace;
                eval "$tmux_navigation_command";
            fi;
        fi;
    elif pane_contains_ssh; then
        eval "$tmux_remote_navigation_command"
        if ! pane_title_changed; then
            eval "$tmux_navigation_command";
        fi
    elif ! pane_is_zoomed; then
        eval "$tmux_navigation_command";
    fi;
};

navigate "$direction"
