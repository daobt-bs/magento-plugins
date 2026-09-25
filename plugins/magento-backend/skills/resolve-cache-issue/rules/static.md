# Static and media rules

## STATIC_ASSET_STALE

Trace the asset from source to deployment to `pub/static`/preprocessed output to browser/CDN response. Compare versions or content hashes where possible. Do not flush Magento application caches merely because CSS or JS is old.

## IMAGE_CACHE_STALE

Inspect the source image, generated derivative under `media/catalog/product/cache`, URL/versioning, and CDN/browser behavior. Regenerate only the affected artifact when the source and derivative mismatch is established.
