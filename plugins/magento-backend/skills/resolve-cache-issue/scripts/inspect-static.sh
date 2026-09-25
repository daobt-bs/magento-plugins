#!/usr/bin/env bash
set -u
printf '%s\n' '=== STATIC_ARTIFACTS ==='
for path in pub/static var/view_preprocessed media/catalog/product/cache; do
  if [[ -e "$path" ]]; then
    printf '%s=' "$path"
    du -sh "$path" 2>/dev/null | awk '{print $1}'
  else
    printf '%s=absent\n' "$path"
  fi
done
