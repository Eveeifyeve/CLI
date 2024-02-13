#!/usr/bin/env bash


# Function to display help message
show_help() {
    local script_path="$0"
    local commands=$(sed -n '/^# Command:/s/^# Command: //p' "$script_path")
    local descriptions=$(sed -n '/^# Description:/s/^# Description: //p' "$script_path")

    local aqua='\033[0;36m' # Aqua color
    local purple='\033[0;35m' # Purple color
    local reset='\033[0m' # Reset color

        printf "${aqua}EveeifyEve ${purple}CLI\n\n${reset}Usage:\n\n${aqua}Commands:\n"

    paste -d '\t' <(echo "$commands") <(echo "$descriptions") | while IFS=$'\t' read -r command description; do
        printf "  ${aqua}%s${reset}\t%s\n" "$command" "$description"
    done

    printf "\n${purple}Options:\n  -h, --help     Show this help message\n${reset}"
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
            red='\033[0;31m'
            reset='\033[0m'
            echo -e "${red}Uncommitted changes detected${reset} at: $repo_dir"
        fi
    done
}


# Command: reinstall
# Description: Reinstalls Apps Again
handle_reinstall() {
    local formulas=("neovim" "tmux" "btop" "gh")
    local casks=("raycast" "wezterm")
    local total_steps=$(( ${#formulas[@]} + ${#casks[@]}   ))
    local step=0
    local start_time=$(date +%s)
    local green='\033[0;32m'
    local reset='\033[0m'

    for formula in "${formulas[@]}"; do
        ((step++))
        local elapsed_time=$(($(date +%s) - $start_time))
        local eta=$(( ($elapsed_time * $total_steps) / $step - $elapsed_time   ))
        local percentage=$(( ($step *   100) / $total_steps   ))
        local progress_bar=$(printf "%*s" $((${#total_steps}-$step)) "" | tr ' ' '#')
        echo -ne "${progress_bar}${green}###${reset} Progress: ${percentage}% ETA: $((eta/60)) minutes $((eta%60)) seconds\r"
        if ! brew list   2>/dev/null | grep -q "^${formula}$"; then
            brew install "${formula}" || true
        fi
    done

    for cask in "${casks[@]}"; do
        ((step++))
        local elapsed_time=$(($(date +%s) - $start_time))
        local eta=$(( ($elapsed_time * $total_steps) / $step - $elapsed_time   ))
        local percentage=$(( ($step *   100) / $total_steps   ))
        local progress_bar=$(printf "%*s" $((${#total_steps}-$step)) "" | tr ' ' '#')
        echo -ne "${progress_bar}${green}###${reset} Progress: ${percentage}% ETA: $((eta/60)) minutes $((eta%60)) seconds\r"
        if ! brew list --cask   2>/dev/null | grep -q "^${cask}$"; then
            brew install --cask "${cask}" >/dev/null   2>&1 || true
        fi
    done
    clear
    echo -e "${green}Reinstallation complete.${reset}"
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