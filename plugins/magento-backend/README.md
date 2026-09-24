# magento-backend

Claude Code plugin for the Magento 2 Backend team — a set of skills for code review, debugging, and security auditing on Magento 2 / Mage-OS.

- **Version:** 1.0.0
- **Author:** Dao BT

## Skills

| Skill | Use when |
|-------|----------|
| [`validate-magento-backend-code`](skills/validate-magento-backend-code/SKILL.md) | Reviewing backend PHP code (a PR diff, a module, or a file) before merge. Checklist covers four areas: coding standard, architecture/best practice, security, performance. |
| [`magento-debug`](skills/magento-debug/SKILL.md) | Diagnosing and fixing issues from a symptom or error log: white page, 500, 404, DI errors, stale cache, performance... |
| [`security-audit`](skills/security-audit/SKILL.md) | Auditing the whole codebase for security: OWASP Top 10, admin/API/payment surfaces, template injection, configuration hardening, third-party module risk. Includes a Quick-Scan mode. |

### validate-magento-backend-code

- Targets Magento-specific failure modes that generic PHP review misses: direct `ObjectManager` usage, unscoped ACL, collection N+1, raw SQL bypassing the ORM...
- Not for frontend-only changes (JS/Knockout/LESS/layout styling).
- Not a substitute for `phpcs`/`phpstan` — run those first, then use this skill for the judgment calls automated tools can't make.

### magento-debug

Workflow: **Identify → Check logs → Run diagnostics → Apply fix → Verify**. Includes a Symptom → Cause → Fix reference table, the log files to check first, a common-pitfalls checklist, how to enable debug mode, and a full reset sequence for when all else fails.

### security-audit

Ten-phase audit: project context → scope & inventory → automated scanning → injection & input validation → authentication & access control → API/endpoint security → template & frontend security → configuration & infrastructure → data protection & payment → third-party module risk. Results follow a report template (Critical / High / Medium / Low findings, hardening recommendations, third-party risk matrix).

## Usage

Claude activates a skill automatically when your request matches its description, for example:

- "Review this PR" → `validate-magento-backend-code`
- "Checkout shows a white page, here's the log..." → `magento-debug`
- "Run a security audit on Vendor_Payment" → `security-audit`

You can also invoke a skill directly as a slash command, e.g. `/magento-backend:security-audit`.

## Adding a new skill

1. Create a directory `skills/<skill-name>/` — the directory name should match the skill's `name`.
2. Add a `SKILL.md` file with frontmatter:
   ```markdown
   ---
   name: <skill-name>
   description: Use when ... (clearly describe when the skill should be used)
   ---
   ```
3. Bump `version` in `.claude-plugin/plugin.json` and in the plugin's entry in the root `.claude-plugin/marketplace.json`, and update the skills table above.
