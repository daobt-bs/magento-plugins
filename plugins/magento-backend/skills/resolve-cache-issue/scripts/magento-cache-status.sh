#!/usr/bin/env bash
set -u
printf '%s\n' '=== CACHE_STATUS ==='
if [[ ! -x bin/magento ]]; then
  printf '%s\n' 'error=bin/magento not found or not executable'
  exit 1
fi
bin/magento cache:status
