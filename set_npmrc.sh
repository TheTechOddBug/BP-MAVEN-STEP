#!/bin/bash

set_npmrc() {
    # Define the directory to check
    CODEBASE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
    TARGET_DIR="${CODEBASE_LOCATION}"

    # Define the global npmrc path
    GLOBAL_NPMRC="$HOME/.npmrc"

    # Check if .npmrc exists in the target directory
    if [[ -f "$TARGET_DIR/.npmrc" ]]; then
        echo "Found .npmrc in $TARGET_DIR. Setting it as default."

        # Backup the existing global .npmrc if it exists
        if [[ -f "$GLOBAL_NPMRC" ]]; then
            mv "$GLOBAL_NPMRC" "$GLOBAL_NPMRC.bak"
            echo "Existing .npmrc backed up as .npmrc.bak"
        fi

        # Use the found .npmrc as the default
        cp "$TARGET_DIR/.npmrc" "$GLOBAL_NPMRC"
        echo "Updated default .npmrc to the one in $TARGET_DIR"

        # Print Node.js, NVM, NPM, and PNPM versions
        echo "--------------------------"
        echo "Environment Versions:"
        echo "--------------------------"
        
        # Load NVM
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            source "$NVM_DIR/nvm.sh"
            echo "NVM Version: $(nvm --version)"
            echo "Active Node.js Version: $(node -v)"
        else
            echo "NVM not found or not installed."
        fi
        
        echo "NPM Version: $(npm -v)"
        echo "PNPM Version: $(pnpm -v)"
    else
        echo "No .npmrc file found in $TARGET_DIR. Using the existing default."
    fi

    # # Verify the active .npmrc
    # echo "Active .npmrc file:"
    # cat "$GLOBAL_NPMRC" 2>/dev/null || echo "No .npmrc found."
}

# set_npmrc
