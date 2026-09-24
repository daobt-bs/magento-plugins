#!/usr/bin/env bash
set -u
printf '%s\n' '=== DOCKER ==='
if command -v docker >/dev/null 2>&1; then
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
else
  printf '%s\n' 'docker=absent'
fi
if docker compose version >/dev/null 2>&1; then
  printf '%s\n' '--- compose ps ---'
  docker compose ps
else
  printf '%s\n' 'docker_compose=absent'
fi
