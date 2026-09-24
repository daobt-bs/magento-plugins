# Local evidence commands

Use only the checks relevant to the hypothesis. Prefer read-only commands first.

## Magento

```bash
bin/magento cache:status
bin/magento cache:status full_page
bin/magento cache:status block_html
bin/magento cache:status config
bin/magento cache:status layout
bin/magento indexer:status
```

## HTTP

```bash
curl -sSI https://example.test/path
```

Inspect `X-Magento-Cache-Debug`, `Age`, `Cache-Control`, `Vary`, `Set-Cookie`, and proxy/CDN headers.

## Redis / Valkey

```bash
redis-cli INFO memory
redis-cli INFO stats
redis-cli INFO server
redis-cli DBSIZE
```

Use the project's configured client/host/db/prefix. Do not guess production endpoints.

## Docker

```bash
docker ps
docker compose ps
docker compose logs <service>
docker inspect <service>
docker stats
```

## Filesystem targets

Inspect as relevant: `var/cache`, `var/page_cache`, `var/view_preprocessed`, `pub/static`, `media/catalog/product/cache`, `generated/code`, `generated/metadata`.
