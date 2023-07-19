#!/bin/bash

function read_input {
    read -p "$1: " value
    echo "$value"
}

function is_valid_type {
    local valid_types=("hotfix" "fix" "feat" "evol" "test" "refactor" "perf" "docs" "ci")
    local input_type=$1

    for type in "${valid_types[@]}"; do
        if [ "$type" == "$input_type" ]; then
            return 0
        fi
    done

    return 1
}

while true; do
    type_of_modification=$(read_input "Type of modification")

    if is_valid_type "$type_of_modification"; then
        break
    else
        echo "Type '$type_of_modification' is not valid. Please enter a valid type from the list: hotfix, fix, feat, evol, test, refactor, perf, docs, ci"
    fi
done

scope=$(read_input "Scope")
title=$(read_input "Title")
description=$(read_input "Description")
issue_number=$(read_input "Issue reference")

user_name=$(git config --global user.name)
user_email=$(git config --global user.email)

commit_message="$type_of_modification($scope): $title

description: $description

Closes #$issue_number"

if [ -n "$user_name" ] && [ -n "$user_email" ]; then
    commit_message+="\n\nSigned-off-by: $user_name <$user_email>"
fi

temp_file=$(mktemp)

echo -e "$commit_message" > "$temp_file"

vim "$temp_file"

read -p "Do you want to commit the changes? (y/N): " commit_choice
case $commit_choice in
    [Yy]* )
        if git commit -F "$temp_file"; then
            echo "Commit created successfully!"
        fi;;
    * )
        echo "Commit was not created.";;
esac

rm "$temp_file"
