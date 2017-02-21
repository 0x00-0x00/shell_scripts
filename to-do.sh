#!/bin/bash
# Shell script to add a To-Do at the conky script Black Pearl
# ------------------- written by zc00l
user_name=$(cat /etc/passwd | grep $(id -u) | grep -oP '[a-zA-Z0-9]+(?=:x)')
todo_file="/home/$user_name/.todo/todo.txt"

# Check if file exists.
if [[ ! -e "$todo_file" ]]; then
    echo "[!] To-do file does not exists.";
    exit;
fi

function check_data
{
    if [[ $1 == "" ]]; then
        echo "[!] No data.";
        exit;
    fi
    return 0
}

if [[ $1 != "add" ]] && [[ $1 != "del" ]]; then
    echo "Usage: $0 add|del data";
    exit;
fi

if [[ $1 == "add" ]]; then
    check_data $2;
    echo "[*] Adding task '$2' ...";
    echo "$2" >> "$todo_file";
    echo "[*] Done."
else
    check_data "$2"
    echo "[*] Removing task with keyword '$2' ..."
    new_file=$(cat "$todo_file" | grep -v "$2")
    echo "$new_file" > "$todo_file"
    echo "[*] Done."
fi

exit;

