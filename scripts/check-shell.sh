#!/usr/bin/env bash
# Validate the syntax of tracked shell scripts without executing provisioning.
# Optional positional arguments limit validation to explicitly named files.
set -euo pipefail

files=()
if (( $# > 0 )); then
  files=("$@")
else
  repo_root="$(git rev-parse --show-toplevel)"
  cd "$repo_root"
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(git ls-files -z -- '*.sh')
fi

if (( ${#files[@]} == 0 )); then
  echo 'ERROR: No tracked shell scripts found; check the repository and file selection.' >&2
  exit 1
fi

failed=0
for file in "${files[@]}"; do
  if bash -n "$file"; then
    printf 'PASS bash -n: %s\n' "$file"
  else
    printf 'FAIL bash -n: %s\n' "$file" >&2
    failed=1
  fi
done

if (( failed )); then
  echo 'Bash syntax validation failed.' >&2
  exit 1
fi

printf 'Bash syntax validation passed for %s script(s).\n' "${#files[@]}"
