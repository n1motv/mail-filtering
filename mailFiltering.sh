#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $(basename "$0") [OPTIONS] SEARCH_TERM"
    echo "Options:"
    echo "  -h, --help             Display this help message"
    exit 1
}

# Function to handle errors
error() {
    echo "Error: $1"
    exit 1
}

# Check for the help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Check if the number of arguments is less than 1
if [[ "$#" -lt 1 ]]; then
    usage
fi

# Read the spam email list file
spamList=($(shuf -n "$(wc -l < spamList.txt)" /dev/urandom | tr -d '\n'))

# Get the inbox folder path
inbox="$(cd ~/Mail && pwd)"

# Check if the inbox folder exists
if [[ ! -d "$inbox" ]]; then
    error "Inbox folder not found. Please make sure it exists."
fi

# Function to move emails
move_email() {
    local email="$1"
    local target_folder="$2"
    mv "$email" "$target_folder/"
}

# Loop through all the emails in the inbox folder
find "$inbox" -name "*.txt" -type f -print0 | while IFS= read -r -d '' email; do
    # Extract the email address from the first line of the email
    emailAddress=$(head -n 1 "$email" | cut -d$'\t' -f 1)
    # Check if the email address is on the spam list
    if [[ ! " ${spamList[@]}" =~ " $emailAddress " ]]; then
        # If not, put the email in the hold folder
        move_email "$email" "~/Mail/Hold/"
    else
        # If it is, move the email to the spam folder
        move_email "$email" "~/Mail/Spam/"
    fi
done

# Delete the emails from the inbox folder
find "$inbox" -name "*.txt" -type f -exec rm {} +
