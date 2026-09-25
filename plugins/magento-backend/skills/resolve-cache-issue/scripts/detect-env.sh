#!/usr/bin/env bash
set -u

printf '%s\n' '=== MAGENTO_CACHE_ENV ==='
if [[ -x bin/magento ]]; then printf '%s\n' 'magento_cli=present'; else printf '%s\n' 'magento_cli=absent'; fi
if [[ -f docker-compose.yml || -f docker-compose.yaml || -f compose.yml || -f compose.yaml ]]; then printf '%s\n' 'docker_compose=present'; else printf '%s\n' 'docker_compose=absent'; fi
if command -v redis-cli >/dev/null 2>&1; then printf '%s\n' 'redis_cli=present'; else printf '%s\n' 'redis_cli=absent'; fi
if [[ -f app/etc/env.php ]]; then printf '%s\n' 'magento_env_php=present'; else printf '%s\n' 'magento_env_php=absent'; fi
if [[ -d generated/code || -d generated/metadata ]]; then printf '%s\n' 'generated_artifacts=present'; else printf '%s\n' 'generated_artifacts=absent'; fi
