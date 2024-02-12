#!/usr/bin/env bash


# Function to display help message
show_help() {
    local script_path="$0"
    local commands=$(sed -n '/^# Command:/s/^# Command: //p' "$script_path")
    local descriptions=$(sed -n '/^# Description:/s/^# Description: //p' "$script_path")

    printf "EveeifyEve CLI\n\nUsage:\n\nCommands:\n"

    paste -d '\t' <(echo "$commands") <(echo "$descriptions") | while IFS=$'\t' read -r command description; do
        printf "  %s\t%s\n" "$command" "$description"
    done

    printf "\nOptions:\n  -h, --help     Show this help message\n"
}

# Command: git_checkFolders
# Description: Checks if you have committed in a folder of projects.
handle_git_checkFolders() {
    if [[ $# -eq   0 ]]; then
        echo "Error: No path provided. Please specify a path to check."
        return   1
    fi

    local path="$1"

    # Convert the path to an absolute path
    path=$(realpath "$path")

    # Check if the path exists
    if [[ ! -d "$path" ]]; then
        echo "Path does not exist or is not a directory: $path"
        return   1
    fi

find "$path" -type d -name '.git' -exec dirname {} \; | while read -r repo_dir; do
    cd "$repo_dir"
    git_status_output=$(git status --porcelain)
    if [[ -n "$git_status_output" ]]; then
        echo "Uncommitted changes detected in repository at: $repo_dir"
    fi
done
}


# Command: reinstall
# Description: Reinstalls Apps Again
handle_reinstall() {
    local formulas=("neovim" "tmux" "btop" "gh")
    local casks=("raycast" "wezterm")

    echo "Checking and installing Homebrew formulas and casks..."

    for formula in "${formulas[@]}"; do
        if ! brew list | grep -q "^${formula}$"; then
            echo "Installing Homebrew formula: ${formula}"
            brew install "${formula}" || true
        else
            echo "Homebrew formula ${formula} is already installed."
        fi
    done

    for cask in "${casks[@]}"; do
        if ! brew list --cask | grep -q "^${cask}$"; then
            echo "Installing Homebrew cask: ${cask}"
            brew install --cask "${cask}" || true
        else
            echo "Homebrew cask ${cask} is already installed."
        fi
    done

    echo "Reinstallation complete."
}




if [[ $# -eq  0 ]]; then
    show_help
    exit  1
fi

case "$1" in
    reinstall)
        shift
        handle_reinstall
        ;;
    git_checkFolders)
        shift
        handle_git_checkFolders "$@"
        ;;
     *)
        echo "Unknown command: $1"
        show_help
        exit  1
        ;;
esac