#!/usr/bin/env bash
# Read-only preflight: do not reveal secrets or host paths.
set -u
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: macOS required"
  exit 2
fi
echo "architecture: $(uname -m)"
fail=0
for c in git node pnpm cloudflared; do
  if command -v "$c" >/dev/null 2>&1; then echo "$c: found"; else echo "$c: MISSING"; fail=1; fi
done
if command -v node >/dev/null 2>&1; then
  major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  if [[ "$major" =~ ^[0-9]+$ ]] && (( major>=24 )); then echo "Node 24+: OK"; else echo "Node 24+: NOT READY"; fail=1; fi
fi
if command -v pnpm >/dev/null 2>&1; then
  major="$(pnpm --version 2>/dev/null | cut -d. -f1)"
  if [[ "$major" == "10" ]]; then echo "pnpm 10: OK"; else echo "pnpm 10: NOT READY"; fail=1; fi
fi
if [[ -d /Applications/Dia.app ]]; then echo "Dia: installed (optional)"; else echo "Dia: absent or elsewhere (optional)"; fi
if (( fail )); then
  echo "RESULT: NOT READY; check runtime PATH before installation."
  exit 1
fi
echo "RESULT: prerequisites ready for review."
