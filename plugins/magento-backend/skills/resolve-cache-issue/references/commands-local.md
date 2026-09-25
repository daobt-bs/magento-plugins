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
curl -sS -D - -o /dev/null https://example.test/path
curl -sS -D - -o /dev/null -H 'X-Magento-Debug: 1' https://example.test/path
```

Inspect `X-Magento-Cache-Debug`, `X-Magento-Cache-Control`, `Age`, `Cache-Control`, `Vary`, `Set-Cookie`, and proxy/CDN headers.

Read the cache-state header with care: on the built-in FPC it is emitted only in developer mode, so its absence on production is not a MISS. Behind Varnish it is always set — `MISS`, `HIT`, or `UNCACHEABLE`. `UNCACHEABLE` is Varnish's own marker for a response it refuses to store (`beresp.uncacheable`), which points at cacheability rather than at a missing entry; `Age` appears only on a Varnish HIT and only when the request carried `X-Magento-Debug`. Request with the cookies from the affected session before drawing conclusions from a cookie-less response.

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
