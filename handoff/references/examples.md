# Handoff Examples

Concrete examples demonstrating effective handoff summaries.

## Example 1: Technical Project

```markdown
# Handoff: API Payment Integration

**Status:** OAuth2 auth implemented, remaining endpoints untested

## Completed Work

**Authentication system:**
- OAuth2 flow with refresh token support, tested against staging
- Credentials stored via keychain integration
- Wrapper class: `/home/claude/project/api/auth_client.py`

**Base HTTP client:**
- Retry with exponential backoff (3 attempts, random jitter)
- Request/response logging for debugging
- Rate limiting handler (100 req/min)

## Pending / Next Steps

- [ ] **Test remaining endpoints** (PRIORITY)
  - To verify: /users, /data/export, /webhooks/subscribe
  - Test suite: `tests/integration/test_api.py`
  - Staging API key in `.env.staging`

- [ ] **Network error handling**
  - Current implementation assumes stable connection
  - Need to handle: timeouts, connection drops, 5xx responses

## Blockers / Gotchas

**Rate limiting without Retry-After:**
- What: API returns 429 with no Retry-After header
- Why: Server-side bug (confirmed with their team)
- Impact: Must use fixed 60s backoff
- Workaround: Hardcoded sleep in rate_limit_handler()

**Token refresh timing:**
- Decision: Refresh 5 minutes before expiry (not 1 minute)
- Rationale: Network delays cause race conditions at 1 minute
- Rejected: 1-minute window (risk of expired token mid-request)

## Learnings

**Exponential backoff:**
- Discovery: Without jitter, all retries fire simultaneously under load (thundering herd)
- Recommendation: `random.uniform(0, base_delay * 2 ** attempt)` for backoff

## Context for Next Conversation

Run the test suite: `pytest tests/integration/test_api.py -v`. Auth tests
pass reliably. Focus on the three untested endpoints. Staging credentials
in `.env.staging`.
```

## Example 2: Skill Design Work

```markdown
# Handoff: agent-core Skills Conversion to claude.ai

**Status:** brief-fr/brief-en done and installed. Passation/handoff and tag in progress.

## Completed Work

**i18n methodology:**
- Grounded methodology document (EMNLP/WMT 2025 research)
- Core principle: native rewrite, not mechanical translation
- Two separate skills per language, shared DESIGN.md in English

**brief-fr and brief-en skills:**
- Installed in `/mnt/skills/user/`
- Shared DESIGN.md with 7 documented decisions (D-1 through D-7)
- Reference model for all future bilingual skill co-writing

**tag skill (FR prototype):**
- Lightweight `🏷️ short label` marker in conversation
- Stripped design: zero content duplication, conversation is the content

## Pending / Next Steps

- [ ] **Create passation (FR) and handoff (EN)** (PRIORITY)
  - Native rewrite of existing conversation-handoff
  - Template and examples in each language
  - Shared DESIGN.md

- [ ] **Create tag-en** (after passation/handoff)
  - Native rewrite of existing tag-fr

- [ ] **Install all skills** in `/mnt/skills/user/`

## Blockers / Gotchas

**Existing conversation-handoff skill:**
- Decision: Replace with passation + handoff (two distinct skills)
- Rationale: Consistent with i18n model, refs in skill's own language
- Old skill stays in place until new ones are installed

**Tag enumeration section removed:**
- Decision: No coupling between tag and passation
- Rationale: Passation already reads the full conversation; tags add no information

## Learnings

**Conversion ≠ porting:**
- Discovery: claude.ai and Claude Code have different constraints, so solutions must differ
- Impact: brief exists because Code agents are isolated; tag exists because conversation_search accesses everything
- Recommendation: Always start from target context constraints, not source implementation

## Context for Next Conversation

Continue building passation/handoff and tag-fr/tag-en skills. i18n
methodology documented in `methodology-skill-i18n.md`. The brief-fr
DESIGN.md is the reference model for all other skill pair DESIGN.md files.
```

## Patterns in Good Handoffs

**Specific:**
- Good: "File at `/home/claude/project/api/auth_client.py`"
- Bad: "The auth file"

**Contextualized:**
- Good: "Refresh 5 min before expiry because 1-min timing had race conditions"
- Bad: "Changed the token refresh timing"

**Actionable:**
- Good: "Run `pytest tests/integration/test_api.py -v` on the three endpoints"
- Bad: "Need to test some more endpoints"

**Root causes:**
- Good: "API returns 429 without Retry-After header (confirmed server bug)"
- Bad: "Rate limiting doesn't work right"
