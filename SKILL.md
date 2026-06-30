# SKILL: Generate a structured CHANGELOG from git history

## Overview
This skill provides a bash script that automatically generates a structured `CHANGELOG.md` from a project's git history.

## Usage

### Option 1: Bash script
```bash
./generate_changelog.sh [repo_path] [since_tag]
```

Examples:
```bash
# Generate from current repo, since last tag
./generate_changelog.sh

# Generate from specific repo and tag
./generate_changelog.sh /path/to/repo v1.0.0
```

### Option 2: Claude Code command
```
/generate-changelog [repo_path] [since_tag]
```

## How it works
1. Fetches git commits since the last tag (or all commits if no tag exists)
2. Categorizes commits into: Added, Fixed, Changed, Removed, Other
3. Outputs a properly formatted `CHANGELOG.md`

## Commit categorization rules
- `feat:` or `feat(...)` → **Added**
- `fix:` or `fix(...)` → **Fixed**
- `refactor:`, `perf:`, `docs:`, `test:`, `chore:` → **Changed**
- `remove:`, `delete:`, `rm:` → **Removed**
- `BREAKING` or `breaking:` → **Changed** (with ⚠️ warning)
- Everything else → **Other**

## Requirements
- Bash 4.0+
- Git
- No external dependencies

## Setup (3 steps)
1. Clone this repository
2. Make the script executable: `chmod +x generate_changelog.sh`
3. Run it: `./generate_changelog.sh`
