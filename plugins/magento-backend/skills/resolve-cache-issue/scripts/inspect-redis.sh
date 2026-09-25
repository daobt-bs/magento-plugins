#!/usr/bin/env bash
set -u
printf '%s\n' '=== REDIS ==='
if ! command -v redis-cli >/dev/null 2>&1; then
  printf '%s\n' 'error=redis-cli not found'
  exit 1
fi
printf '%s\n' '--- INFO memory ---'
redis-cli INFO memory | awk -F: '/^(used_memory|used_memory_peak|maxmemory|maxmemory_policy):/ {print}'
printf '%s\n' '--- INFO stats ---'
redis-cli INFO stats | awk -F: '/^(keyspace_hits|keyspace_misses|evicted_keys):/ {print}'
printf '%s\n' '--- INFO server ---'
redis-cli INFO server | awk -F: '/^(redis_version|uptime_in_seconds):/ {print}'
printf '%s\n' '--- DBSIZE ---'
redis-cli DBSIZE
