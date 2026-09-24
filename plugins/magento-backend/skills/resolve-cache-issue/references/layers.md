# Magento cache and cache-like layers

```text
Browser
  -> CDN / Fastly / reverse proxy
  -> Varnish where applicable
  -> Magento Full Page Cache
  -> Block HTML / fragment cache
  -> Magento application cache types
  -> Redis / Valkey / filesystem / DB backend
  -> Private content / customer-data browser state
  -> Static content and media derivatives
  -> Generated code / metadata
  -> PHP OPcache
  -> Database / indexers / search infrastructure
```

## Important distinctions

- Database and indexers are not Magento cache types.
- Generated code and OPcache are runtime staleness layers, not Magento cache types.
- Public page HTML can be cached while customer-specific content refreshes separately.
- The exact Magento cache type list depends on the installed version and modules; inspect the target project.

## High-value source signals

For block/FPC behavior inspect `cacheable="false"`, `getCacheKeyInfo()`, `getIdentities()` / `IdentityInterface`, cache lifetime, layout XML, `sections.xml`, and custom invalidation logic.

For HTTP behavior inspect `X-Magento-Cache-Debug`, `Age`, `Cache-Control`, `Vary`, `Set-Cookie`, and CDN/Varnish-specific headers.
