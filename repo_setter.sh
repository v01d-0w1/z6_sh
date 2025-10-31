#!/bin/bash

# Prompt user
read -p "Enter project path: " path
read -p "Enter repository URL: " repo

echo "path: $path"
echo "repo_url: $repo"

# Ensure directory exists
cd "$path" || { echo "Error: Directory '$path' not found."; exit 1; }

# Set global Git config (optional – remove if already configured)
git config --global user.name "v01d-0w1"
git config --global user.email "tnz426.z6@gmail.com"

# Initialize Git if not already initialized
if [ -d ".git" ]; then
    echo "Git repo already exists."
else
    git init -b main
    echo "Initialized Git repo with 'main' as the default branch."
fi

# Rename branch to 'main' if it's not already
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "main" ]; then
    git branch -m main
    echo "Renamed current branch to 'main'."
fi

# Stage all files
git add .

# Only commit if there are staged changes
if git diff --cached --quiet; then
    echo "No changes to commit."
else
    git commit -m "Initial commit"
    echo "Committed changes."
fi

# Set or update remote
if git remote | grep -q origin; then
    git remote set-url origin "$repo"
    echo "Updated existing 'origin' remote."
else
    git remote add origin "$repo"
    echo "Added new 'origin' remote."
fi

# Push only if branch has commits
if [ "$(git rev-parse --verify main 2>/dev/null)" ]; then
    git push -u origin main
else
    echo "No commits to push. Skipping push."
fi

