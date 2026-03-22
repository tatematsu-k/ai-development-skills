#!/usr/bin/env bash
# generate-cursor-rules.sh
#
# Convert Claude Code plugin skills, commands, and agents into
# Cursor-compatible .mdc rule files under cursor/rules/.
#
# Usage: bash scripts/generate-cursor-rules.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$REPO_ROOT/cursor/rules"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ── Helper: extract YAML frontmatter value ──────────────────────────
yaml_val() {
  local file="$1" key="$2"
  sed -n '/^---$/,/^---$/p' "$file" \
    | grep "^${key}:" \
    | sed "s/^${key}:[[:space:]]*//" \
    | sed 's/^["'"'"']\(.*\)["'"'"']$/\1/' \
    || true
}

# ── Helper: extract body (everything after second ---) ──────────────
body_after_frontmatter() {
  local file="$1"
  # If file starts with ---, skip frontmatter
  if head -1 "$file" | grep -q '^---$'; then
    awk 'BEGIN{n=0} /^---$/{n++; if(n==2){found=1; next}} found{print}' "$file"
  else
    cat "$file"
  fi
}

# ── Convert Skills ──────────────────────────────────────────────────
convert_skill() {
  local skill_dir="$1"
  local plugin_name="$2"
  local skill_file="$skill_dir/SKILL.md"
  [[ -f "$skill_file" ]] || return 0

  local name
  name=$(yaml_val "$skill_file" "name")
  [[ -z "$name" ]] && name=$(basename "$skill_dir")

  local description
  description=$(yaml_val "$skill_file" "description")
  [[ -z "$description" ]] && description="Skill: $name"

  local body
  body=$(body_after_frontmatter "$skill_file")

  local out_file="$OUTPUT_DIR/${plugin_name}--${name}.mdc"

  cat > "$out_file" <<ENDMDC
---
description: "${description}"
globs:
alwaysApply: false
---

${body}
ENDMDC

  echo "  skill: $out_file"
}

# ── Convert Commands ────────────────────────────────────────────────
convert_command() {
  local cmd_file="$1"
  local plugin_name="$2"
  local cmd_name
  cmd_name=$(basename "$cmd_file" .md)

  local description
  description=$(yaml_val "$cmd_file" "description")

  local body
  body=$(body_after_frontmatter "$cmd_file")

  # If no frontmatter description, use first non-empty line as description
  if [[ -z "$description" ]]; then
    description=$(echo "$body" | sed '/^$/d' | head -1 | sed 's/^#* *//')
  fi

  local out_file="$OUTPUT_DIR/${plugin_name}--cmd-${cmd_name}.mdc"

  cat > "$out_file" <<ENDMDC
---
description: "Command /${cmd_name}: ${description}"
globs:
alwaysApply: false
---

${body}
ENDMDC

  echo "  command: $out_file"
}

# ── Convert Agents ──────────────────────────────────────────────────
convert_agent() {
  local agent_file="$1"
  local plugin_name="$2"
  local agent_name
  agent_name=$(basename "$agent_file" .md)

  local description
  description=$(yaml_val "$agent_file" "description")
  [[ -z "$description" ]] && description="Agent: $agent_name"

  local body
  body=$(body_after_frontmatter "$agent_file")

  local out_file="$OUTPUT_DIR/${plugin_name}--agent-${agent_name}.mdc"

  cat > "$out_file" <<ENDMDC
---
description: "Agent ${agent_name}: ${description}"
globs:
alwaysApply: false
---

${body}
ENDMDC

  echo "  agent: $out_file"
}

# ── Main ────────────────────────────────────────────────────────────
echo "Generating Cursor rules from Claude Code plugins..."
echo ""

for plugin_dir in "$REPO_ROOT"/plugins/*/; do
  plugin_name=$(basename "$plugin_dir")
  echo "Plugin: $plugin_name"

  # Skills
  if [[ -d "$plugin_dir/skills" ]]; then
    for skill_dir in "$plugin_dir"/skills/*/; do
      [[ -d "$skill_dir" ]] && convert_skill "$skill_dir" "$plugin_name"
    done
  fi

  # Commands
  if [[ -d "$plugin_dir/commands" ]]; then
    for cmd_file in "$plugin_dir"/commands/*.md; do
      [[ -f "$cmd_file" ]] && convert_command "$cmd_file" "$plugin_name"
    done
  fi

  # Agents
  if [[ -d "$plugin_dir/agents" ]]; then
    for agent_file in "$plugin_dir"/agents/*.md; do
      [[ -f "$agent_file" ]] && convert_agent "$agent_file" "$plugin_name"
    done
  fi

  echo ""
done

total=$(find "$OUTPUT_DIR" -name '*.mdc' | wc -l)
echo "Done! Generated $total .mdc files in cursor/rules/"
