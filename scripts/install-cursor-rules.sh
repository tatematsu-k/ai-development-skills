#!/usr/bin/env bash
# install-cursor-rules.sh
#
# Install generated .mdc rules into a target project's .cursor/rules/ directory.
#
# Usage:
#   bash scripts/install-cursor-rules.sh /path/to/your/project
#   bash scripts/install-cursor-rules.sh                         # installs to current directory
#
# Options:
#   --plugin=aidlc    Install only aidlc rules
#   --plugin=ecc      Install only ecc rules
#   --symlink         Create symlinks instead of copying (keeps rules in sync)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RULES_SRC="$REPO_ROOT/cursor/rules"

TARGET_DIR=""
PLUGIN_FILTER=""
USE_SYMLINK=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --plugin=*)
      PLUGIN_FILTER="${arg#--plugin=}"
      ;;
    --symlink)
      USE_SYMLINK=true
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
    *)
      TARGET_DIR="$arg"
      ;;
  esac
done

# Default to current directory
[[ -z "$TARGET_DIR" ]] && TARGET_DIR="$(pwd)"

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DEST="$TARGET_DIR/.cursor/rules"

# Check source exists
if [[ ! -d "$RULES_SRC" ]]; then
  echo "Error: cursor/rules/ not found. Run scripts/generate-cursor-rules.sh first." >&2
  exit 1
fi

# Create destination
mkdir -p "$DEST"

echo "Installing Cursor rules to: $DEST"
[[ -n "$PLUGIN_FILTER" ]] && echo "Filter: plugin=$PLUGIN_FILTER"
[[ "$USE_SYMLINK" == true ]] && echo "Mode: symlink" || echo "Mode: copy"
echo ""

count=0
for mdc_file in "$RULES_SRC"/*.mdc; do
  [[ -f "$mdc_file" ]] || continue

  filename=$(basename "$mdc_file")

  # Apply plugin filter if specified
  if [[ -n "$PLUGIN_FILTER" ]]; then
    if [[ ! "$filename" =~ ^${PLUGIN_FILTER}-- ]]; then
      continue
    fi
  fi

  if [[ "$USE_SYMLINK" == true ]]; then
    ln -sf "$mdc_file" "$DEST/$filename"
  else
    cp "$mdc_file" "$DEST/$filename"
  fi

  count=$((count + 1))
done

echo "Installed $count rule files."
echo ""
echo "Tips:"
echo "  - Rules with alwaysApply: false are activated by Cursor when matching the description"
echo "  - To always apply specific rules, edit the .mdc file and set alwaysApply: true"
echo "  - To limit rules to specific files, set the globs field (e.g., globs: \"**/*.ts\")"
