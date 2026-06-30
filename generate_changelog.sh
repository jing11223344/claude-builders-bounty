#!/bin/bash
# generate_changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: ./generate_changelog.sh [repo_path] [since_tag]

set -euo pipefail

REPO="${1:-.}"
SINCE_TAG="${2:-$(git -C "$REPO" describe --tags --abbrev=0 2>/dev/null || echo '')}"

cd "$REPO"

ADDED_F=$(mktemp)
FIXED_F=$(mktemp)
CHANGED_F=$(mktemp)
REMOVED_F=$(mktemp)
OTHER_F=$(mktemp)
trap "rm -f $ADDED_F $FIXED_F $CHANGED_F $REMOVED_F $OTHER_F" EXIT

if [ -z "$SINCE_TAG" ]; then
    COMMITS=$(git log --pretty=format:"%s" 2>/dev/null | head -100)
else
    COMMITS=$(git log "$SINCE_TAG"..HEAD --pretty=format:"%s" 2>/dev/null)
fi

if [ -z "$COMMITS" ]; then
    echo "No commits found."
    exit 0
fi

while IFS= read -r commit; do
    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    if echo "$lower_commit" | grep -qE '^feat'; then
        echo "- $commit" >> "$ADDED_F"
    elif echo "$lower_commit" | grep -qE '^fix'; then
        echo "- $commit" >> "$FIXED_F"
    elif echo "$lower_commit" | grep -qE 'breaking'; then
        printf '\xe2\x9a\xa0\ufe0f - %s\n' "$commit" >> "$CHANGED_F"
    elif echo "$lower_commit" | grep -qE '^(refactor|perf|docs|doc|test|chore|style|build|ci|config)'; then
        echo "- $commit" >> "$CHANGED_F"
    elif echo "$lower_commit" | grep -qE '^(remove|delete|rm)'; then
        echo "- $commit" >> "$REMOVED_F"
    else
        echo "- $commit" >> "$OTHER_F"
    fi
done <<< "$COMMITS"

cat << 'HEADER'
# Changelog

All notable changes to this project will be documented in this file.

HEADER

echo "## [Unreleased]"
echo ""
[ -s "$ADDED_F" ] && echo "### Added" && cat "$ADDED_F" && echo ""
[ -s "$FIXED_F" ] && echo "### Fixed" && cat "$FIXED_F" && echo ""
[ -s "$CHANGED_F" ] && echo "### Changed" && cat "$CHANGED_F" && echo ""
[ -s "$REMOVED_F" ] && echo "### Removed" && cat "$REMOVED_F" && echo ""
[ -s "$OTHER_F" ] && echo "### Other" && cat "$OTHER_F" && echo ""
