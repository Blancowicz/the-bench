#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# the-bench install script
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/tu-org/the-bench/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/tu-org/the-bench/main/install.sh | bash -s -- --upgrade
#   ./install.sh [--upgrade] [--project /path/to/project]
# ─────────────────────────────────────────────

REPO_URL="git@github.com:Blancowicz/the-bench.git"
BENCH_DIR="$(mktemp -d)"
UPGRADE=false
PROJECT_DIR="${PWD}"

# ── Parse arguments ───────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --upgrade)   UPGRADE=true; shift ;;
    --project)   PROJECT_DIR="$2"; shift 2 ;;
    *)           echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# ── Colors ────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}▸ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠ $1${NC}"; }
error()   { echo -e "${RED}✗ $1${NC}"; exit 1; }

# ── Cleanup on exit ───────────────────────────
cleanup() { rm -rf "$BENCH_DIR"; }
trap cleanup EXIT

# ── Validate project dir ──────────────────────
[[ -d "$PROJECT_DIR" ]] || error "Project directory not found: $PROJECT_DIR"
info "Project: $PROJECT_DIR"

# ── Clone the-bench ───────────────────────────
info "Cloning the-bench..."
git clone --depth 1 "$REPO_URL" "$BENCH_DIR" --quiet \
  || error "Failed to clone the-bench. Check your SSH access to $REPO_URL"
success "Cloned the-bench"

# ── Directories ───────────────────────────────
AGENTS_DST="$PROJECT_DIR/.claude/agents"
COMMANDS_DST="$PROJECT_DIR/.claude/commands"
CONTEXT_DST="$PROJECT_DIR/context"
INFRA_DST="$PROJECT_DIR/infra"

mkdir -p "$AGENTS_DST" "$COMMANDS_DST" "$CONTEXT_DST" "$INFRA_DST"

# ─────────────────────────────────────────────
# AGENTS & COMMANDS — always overwrite
# These are the-bench source files, not user config.
# ─────────────────────────────────────────────
info "Installing agents..."
cp "$BENCH_DIR"/agents/*.md "$AGENTS_DST"/
cp "$BENCH_DIR"/_base.md "$AGENTS_DST"/_base.md
cp "$BENCH_DIR"/_context_loader.md "$AGENTS_DST"/_context_loader.md
success "Agents installed → .claude/agents/"

info "Installing commands..."
cp "$BENCH_DIR"/commands/*.md "$COMMANDS_DST"/
success "Commands installed → .claude/commands/"

# ─────────────────────────────────────────────
# TEMPLATES — only copy if not present (install)
#             or skip entirely (upgrade)
# These are user config files. Never overwrite.
# ─────────────────────────────────────────────
copy_template() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if $UPGRADE; then
    warn "Skipped (upgrade mode, preserving user config): $label"
  elif [[ -f "$dst" ]]; then
    warn "Skipped (already exists): $label"
  else
    cp "$src" "$dst"
    success "Created: $label"
  fi
}

info "Installing templates..."
copy_template \
  "$BENCH_DIR/templates/manifest.json.template" \
  "$CONTEXT_DST/manifest.json" \
  "context/manifest.json"

copy_template \
  "$BENCH_DIR/templates/environments.json.template" \
  "$INFRA_DST/environments.json" \
  "infra/environments.json"

copy_template \
  "$BENCH_DIR/templates/SESSION.md.template" \
  "$PROJECT_DIR/SESSION.md" \
  "SESSION.md"

# ─────────────────────────────────────────────
# GITIGNORE — append entries if not present
# ─────────────────────────────────────────────
GITIGNORE="$PROJECT_DIR/.gitignore"
touch "$GITIGNORE"

append_if_missing() {
  local entry="$1"
  if ! grep -qxF "$entry" "$GITIGNORE"; then
    echo "$entry" >> "$GITIGNORE"
    success "Added to .gitignore: $entry"
  else
    warn "Already in .gitignore: $entry"
  fi
}

info "Updating .gitignore..."
append_if_missing ".claude/agent-memory-local/"
append_if_missing "infra/environments.json"

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}────────────────────────────────────────${NC}"
if $UPGRADE; then
  echo -e "${GREEN}  the-bench upgraded successfully${NC}"
else
  echo -e "${GREEN}  the-bench installed successfully${NC}"
fi
echo -e "${GREEN}────────────────────────────────────────${NC}"

if ! $UPGRADE; then
  echo ""
  echo "Next steps:"
  echo "  1. Edit context/manifest.json   — map context folders to your project structure"
  echo "  2. Edit infra/environments.json — add AWS profiles and Terraform version"
  echo "  3. Edit SESSION.md              — update the initial date entry"
  echo ""
  echo "  Then open Claude Code and run /agents to verify agents are loaded."
fi
echo ""
