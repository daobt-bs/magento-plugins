---
name: validate-code
description: Use when reviewing Magento 2 backend PHP code (a PR diff, a module, or a specific file) before merge — checks coding standard, architecture/best-practice, security, and performance issues specific to Magento 2.
---

# Validate Magento Backend Code

## Overview

Checklist-driven review for Magento 2 backend PHP across four dimensions: coding standard, architecture/best-practice, security, performance. Magento's DI-heavy, event/plugin-driven architecture creates failure modes generic PHP review misses (ObjectManager misuse, unscoped ACL, collection N+1, raw SQL bypassing the ORM) — this skill targets those specifically.

## When to Use

- Reviewing a PR/diff before merge
- Auditing a module or a specific file on request
- NOT for frontend-only changes (JS/Knockout/LESS/.phtml layout XML styling) — use a frontend-focused review for those
- NOT a substitute for running the project's own `phpcs`/`phpstan` if configured — run those first, then apply this checklist to what automated tools can't catch (judgment calls, architecture, business logic)

## Workflow

1. **Scope it.** Diff-only (`git diff`) for a PR, or full file/module if asked to audit.
2. **Run automated tools if available** — `vendor/bin/phpcs --standard=Magento2`, `phpstan`, `vendor/bin/phpcs` security sniffs. Don't manually re-check what a linter already covers; spend judgment on what it can't see.
3. **Walk each changed file against the four-dimension checklist below.**
4. **Report findings** using the Output Template below, ordered Security > Architecture/Correctness > Performance > Style.
5. If a file has zero findings in a dimension, don't pad the report saying so — only report actual findings.

## Output Template

Use this structure for every review. Omit a severity section entirely if it has no findings — never write "no issues found" as a line item.

```markdown
## Magento Backend Code Review — <scope: PR #123 / module name / file path>

### Critical (Security)
1. **<short title>** — `<file>:<line>`
   - Issue: <what's wrong>
   - Why it matters: <impact — data leak, RCE, unauthorized access, etc.>
   - Fix: <concrete suggested fix, code-level if short>

### High (Architecture / Correctness)
2. **<short title>** — `<file>:<line>`
   - Issue: ...
   - Why it matters: ...
   - Fix: ...

### Medium (Performance)
3. **<short title>** — `<file>:<line>`
   - Issue: ...
   - Why it matters: ...
   - Fix: ...

### Low (Coding Standard / Style)
4. **<short title>** — `<file>:<line>`
   - Issue: ...
   - Fix: ...

### Summary
- Files reviewed: <n>
- Findings: <critical count> critical, <high count> high, <medium count> medium, <low count> low
- Automated tools run: <phpcs/phpstan output referenced, or "none configured in repo">
- Verdict: <Blocking — must fix before merge / Approve with comments / Approve>
```

Numbering is sequential across the whole report (not reset per section), so each finding can be referenced by number in follow-up discussion. Keep "Issue"/"Why it matters"/"Fix" each to 1–2 sentences — this is a review comment, not a design doc.

## Checklist

### 1. Security (highest severity)

| Check | Red flag | Fix |
|---|---|---|
| SQL injection | Raw string concatenation into `$connection->query()`/`fetchAll()` instead of bound parameters | Use `$connection->select()` + `bind()`, or `?`/named placeholders |
| ACL / admin access | Admin controller without `const ADMIN_RESOURCE` matching an `acl.xml` entry, or `_isAllowed()` not overridden when it should restrict further | Every `Magento\Backend\App\Action` controller must declare `ADMIN_RESOURCE` |
| Input validation | `getRequest()->getParam()` used directly (in SQL, file paths, shell commands) without casting/validating | Cast to expected type (`(int)`), validate against allow-list, use `Filesystem`/`DriverInterface` not raw `fopen` on user-controlled paths |
| CSRF | Custom form/AJAX endpoint without `\Magento\Framework\App\CsrfAwareActionInterface` or form-key check where Magento would normally enforce one | Implement CSRF interface or verify form key |
| Secrets | Hardcoded API keys/passwords/tokens in code | Use `Magento\Framework\App\Config\ScopeConfigInterface` + encrypted config (`core_config_data` with `backend_model=encrypted`), never commit secrets |
| XSS / output escaping | Raw `echo`/block output of user data in `.phtml` without `$block->escapeHtml()`/`escapeUrl()`/`escapeJs()` | Always escape output in templates |
| Serialization | `unserialize()` on user/external input | Use `Magento\Framework\Serialize\SerializerInterface` (JSON) |

### 2. Architecture & Best Practice

| Check | Red flag | Fix |
|---|---|---|
| ObjectManager misuse | `ObjectManager::getInstance()` called directly outside of `di.xml`/factory/plugin bootstrap context | Inject dependencies via constructor |
| Core code untouched | Any edit under `vendor/magento/*` | Override via plugin, preference, or `app/code` module — never edit vendor |
| Service contracts | Direct model manipulation (`->load()`, `->save()`) in a controller/API instead of a Repository/Service Contract | Use `*RepositoryInterface` for data access where one exists |
| Plugin/observer scope | Observer or plugin doing heavy business logic that belongs in a service class | Keep observers/plugins thin — delegate to injected service |
| Dependency direction | Module `A` referencing module `B` without a declared `<sequence>`/composer dependency, or a circular module dependency | Declare dependencies explicitly in `module.xml`/`composer.json` |
| DI configuration | `di.xml` `type`/`preference` overriding a class Magento core already extends elsewhere (silent conflict) | Prefer plugins over blanket preference overrides when only intercepting behavior |
| Naming/PSR-4 | Class/namespace doesn't match Magento's `Vendor_Module` → `Vendor\Module` PSR-4 mapping | Match folder structure to namespace |
| File I/O & responses | Raw `fopen`/`fwrite` on app paths, or a controller writing a file to disk and returning a plain string instead of a proper `ResultInterface` | Use `Filesystem`/`DriverInterface` for paths under `var`/`media`; use `FileFactory` to stream file downloads with correct headers |

### 3. Performance

| Check | Red flag | Fix |
|---|---|---|
| N+1 loads | `->load($id)` or `->create()->load()` called inside a `foreach` | Load a collection once with `addFieldToFilter('entity_id', ['in' => $ids])` |
| Unfiltered collections | Collection loaded without `addFieldToFilter`/`setPageSize`, then filtered in PHP | Filter/paginate at the DB layer |
| Unneeded attributes | `addAttributeToSelect('*')` when only a few fields are used | Select only needed attributes |
| Cache | Expensive computed data (config, API calls) not cached via `CacheInterface`/`Magento\Framework\App\Cache` | Cache with appropriate tag + TTL |
| Reindex triggers | Save operations that will trigger full reindex on every request instead of batch/scheduled | Batch writes, use indexer's scheduled mode where applicable |

### 4. Coding Standard (PSR-12 / Magento Coding Standard)

| Check | Red flag |
|---|---|
| Type declarations | Missing param/return types on new methods |
| Visibility | Missing explicit `public`/`protected`/`private` |
| Magic numbers/strings | Unexplained literals instead of class constants |
| `@api` / `@deprecated` | New public interface not marked `@api` when intended for extension; deprecated methods still called |
| Docblocks | Missing `@param`/`@return`/`@throws` on public interface methods (required by Magento CS, not just style) |

If a repo config exists, prefer it over this table: check for `phpcs.xml`/`phpcs.xml.dist` and defer to its ruleset.

## Common Mistakes When Reviewing

- Treating this as a style-only pass and missing ObjectManager misuse or raw SQL — those are the highest-value catches, always check security + architecture first.
- Flagging `ObjectManager::getInstance()` inside a factory class or `Bootstrap.php` itself — that's the one legitimate place it's allowed.
- Missing that a controller extends `\Magento\Backend\App\Action` but has no `ADMIN_RESOURCE` — easy to skim past.
- Reporting phpcs-catchable style nits when the task is to also run phpcs — don't duplicate what the linter already reports, focus on what only a human/architecture read catches.
