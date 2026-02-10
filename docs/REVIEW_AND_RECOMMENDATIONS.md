# Application Review & Recommendations

Comprehensive review of the Kurzy video course e-shop — covering documentation gaps,
security, models, missing features, video protection, authentication, payments,
architecture, and best practices from similar platforms (Teachable, Thinkific, Udemy, Kajabi).

**Date:** 2026-02-10
**Codebase state:** 15 models, 31+ controllers, Stripe checkout, OAuth (Google/Facebook), R2 storage.

---

## 1. Documentation Gaps

### Missing Documents

| Document | Why It's Needed |
|----------|-----------------|
| `DEPLOYMENT.md` | No Heroku setup, Procfile, env vars checklist, or release tasks documented. |
| `DEVELOPMENT.md` | No local setup guide (Ruby version, `bin/setup`, seed data, port 3001). |
| `FAKTUROID.md` | Referenced in PROJECT_PLAN but no doc exists; CZ invoicing is legally required. |
| `EMAIL_SETUP.md` | No SendGrid / transactional email documentation. |
| `COUPON_SYSTEM.md` | Complex coupon logic exists but is undocumented. |
| `BACKUP_RESTORE.md` | Mentioned as "operational must-have" in plan, never created. |

### Stale / Incomplete Existing Docs

- **STRIPE_SETUP.md** is thin — doesn't mention `checkout.session.expired`,
  `charge.refunded`, or `checkout.session.async_payment_succeeded`
  (all listed in PROJECT_PLAN Phase 3).
- **MEDIA_SECURITY.md** mentions enrollment checks as "remaining gap" but
  enrollments are already implemented — doc is stale.
- **STREAMING_PIPELINE.md** is manual/laptop-only — no mention of automated
  encoding or how it integrates with the admin upload flow.

---

## 2. Security Issues & Concerns

### Critical

1. **No Pundit / authorization gem installed.**
   PROJECT_PLAN recommends Pundit but it's not in the Gemfile. Authorization is
   ad-hoc in controllers. This means:
   - No policy objects, no consistent enforcement.
   - Easy to forget an authorization check on a new endpoint.
   - No `after_action :verify_authorized` safety net.

2. **Stripe webhook idempotency not guaranteed.**
   The plan mentions idempotency but `StripeWebhooksController` only handles
   `checkout.session.completed`. If Stripe retries a webhook, duplicate
   enrollments could be created. Check if order is already `paid` before
   processing.

3. **No rate limiting.**
   No `rack-attack` or similar. Login/OAuth endpoints, cart, checkout, and
   webhook endpoints are all vulnerable to abuse.

4. **SQLite in development, PostgreSQL in production.**
   Behavior differences (unique constraints, JSON, text handling) can cause
   bugs that only appear in production. Use PG everywhere.

5. **No CSRF protection verification for Stripe webhooks.**
   `StripeWebhooksController` should skip `verify_authenticity_token` and rely
   solely on Stripe signature verification. Verify this is correctly
   implemented.

6. **No Content Security Policy (CSP).**
   No CSP headers configured. When video.js or any player is added, a proper
   CSP is needed to prevent XSS vectors.

### Important

7. **Signed URL expiry is 1 hour** — quite long. For video protection,
   5-15 minutes with the player refreshing the URL is better practice.

8. **No account linking for OAuth.**
   If a user signs in with Google using `user@gmail.com`, then later tries
   Facebook with the same email, what happens? Likely creates a second user
   or fails. An account-linking strategy is needed (see Section 6).

9. **No session concurrency controls.**
   The stated goal is preventing login sharing, but nothing prevents a user
   from sharing their Google session or having multiple active sessions.
   Options:
   - Track active sessions (store session token in DB).
   - Limit concurrent sessions (e.g., max 2-3).
   - Show "active sessions" in user settings.

10. **No audit logging implemented.**
    The `AuditLog` model is in the plan but not in the schema. Admin actions
    (delete user, revoke enrollment, delete order) are untracked.

11. **Admin password reset routes are active** (Devise recoverable).
    Ensure the mailer actually works, or disable recoverable if not needed.

---

## 3. Model & Schema Gaps

### Missing Models

| Model | Purpose |
|-------|---------|
| `AuditLog` | In the plan but not implemented. Critical for ops. Fields: `admin_id`, `action`, `record_type`, `record_id`, `metadata` (jsonb). |
| `CourseTag` / `CourseTagging` | In the plan, not implemented. Needed for discovery and recommendations. |
| `Gift` | Gifted courses flow is in Phase 5 but no model exists. |
| `UserSession` | For concurrent session tracking/limiting. Fields: `user_id`, `session_token`, `ip_address`, `user_agent`, `last_active_at`. |
| `Invoice` | Track Fakturoid invoice ID, status, PDF URL per order. |
| `OauthIdentity` | For account linking across providers. Fields: `user_id`, `provider`, `uid`, `email`, `auth_data` (jsonb). |
| `BillingProfile` | For Fakturoid/invoice details. Fields: `user_id`, `company_name`, `ico`, `dic`, `street`, `city`, `zip`, `country`. |

### Schema Issues on Existing Models

1. **Enrollment has no `status` field.**
   The plan says `status: active/revoked/refunded` and `revoked_at`, but the
   actual migration only has `granted_at`. Access cannot be revoked without a
   status field.

2. **Order missing `refunded_at` / refund tracking.**
   Plan mentions refund flow but no fields exist for it.

3. **No `stripe_customer_id` on User.**
   The plan mentions it. Without it, each checkout creates a new Stripe
   customer, making refunds and customer management harder.

4. **No billing details on Order or User.**
   Fakturoid needs company name, ICO, DIC, address. These fields don't exist
   anywhere.

5. **No `title_snapshot` on OrderItem.**
   The plan recommends it (captures course name at time of purchase so
   renaming a course doesn't break order history).

6. **No `email_snapshot` on Order.**
   If user changes email after purchase, the purchase email trail is lost.

7. **Coupon `currency` field exists but `percent`-type coupons don't need it.**
   Minor, but could confuse admin during coupon creation.

---

## 4. Missing Features for MVP

### Must-Have Before Launch

1. **Transactional emails.**
   No mailers exist. At minimum:
   - Purchase confirmation.
   - Enrollment granted.
   - Invoice/receipt (or Fakturoid handles this).
   - Admin notification: new order.

2. **Background jobs.**
   Sidekiq is in the plan but `ApplicationJob` is empty. Needed for:
   - Stripe webhook handling (move out of request cycle).
   - Fakturoid invoice creation.
   - Email delivery.
   - Video processing (future).

3. **Error monitoring.**
   No Sentry or equivalent. Production errors will be missed.

4. **Fakturoid integration.**
   Czech law requires proper invoices for B2C/B2B sales. This is legal
   compliance, not optional.

5. **Admin refund/revoke flow.**
   Cannot handle disputes or refunds without it.

6. **Legal pages content.**
   Views exist (`terms`, `privacy`, `disclaimer`, `data_deletion`) — verify
   they have real content, especially for GDPR compliance.

7. **User data export.**
   GDPR requires users to be able to export their data. Account deletion
   exists but not export.

### Should-Have for MVP

8. **Order confirmation page with details.**
   `checkouts/success.html.erb` may be a generic message — should show order
   summary with course links.

9. **Email verification for OAuth users.**
   Google provides verified email, Facebook may not always. Consider requiring
   email verification from Facebook.

10. **Custom 404/500 error pages.**
    Rails defaults are not user-friendly.

---

## 5. Video Protection & Streaming

### MVP (Current Approach — Good Enough)

Auth-gated signed URLs is solid for MVP. It's what Teachable started with.

### Post-MVP: HLS with video.js

**Recommended stack:**
- **video.js** + native HLS support (or hls.js) — industry standard.
- **Encoding:** ffmpeg for multi-bitrate HLS (360p, 720p, 1080p).
- **Delivery:** Cloudflare R2 + Cloudflare Worker for token-validated segment delivery.

**Key architecture decisions:**

1. **Sign the master playlist, not individual segments.**
   Have the Rails endpoint serve the `.m3u8` playlist with short-lived tokens.
   The Cloudflare Worker validates the token and serves `.ts` segments. This
   avoids signing thousands of URLs.

2. **Use a Cloudflare Worker as auth proxy.**
   The Worker sits in front of R2, validates a JWT/HMAC token on each segment
   request. Far more performant than routing through the Rails app.

3. **Adaptive bitrate is important.**
   Czech internet varies. Having 360p/720p/1080p makes the experience much
   smoother.

4. **Don't use DRM for MVP.**
   Widevine/FairPlay DRM is expensive, complex, and overkill. Czech
   educational content has low piracy risk. Focus on convenience barriers,
   not unbreakable protection.

### Anti-Copy Measures (Layered)

| Layer | Difficulty | Effectiveness |
|-------|-----------|---------------|
| Short-lived signed URLs (current) | Easy | Good — prevents link sharing |
| HLS streaming (no direct download) | Medium | Good — no single file to download |
| Dynamic watermark (user email overlay) | Medium | Excellent deterrent — identifies leaker |
| Session concurrency limits | Easy | Good — prevents credential sharing |
| Cloudflare Worker token validation | Medium | Good — prevents URL harvesting |
| Disable right-click / dev tools detection | Easy | Low — trivially bypassed, deters casual users only |

**Recommendation:** Signed URLs + HLS + dynamic watermark + session limits
gives 95% of the protection for 10% of the cost of DRM.

### Dynamic Watermark Implementation

Two approaches:

1. **CSS/Canvas overlay (simple, post-MVP):**
   Overlay a semi-transparent `<div>` on the video player showing user email
   or order ID. Can be bypassed by determined users but deters casual sharing.

2. **Burned-in watermark (advanced, future):**
   Use ffmpeg to encode the watermark into the video itself, per-user. Requires
   per-user encoding — expensive and complex. Only worth it for very high-value
   content.

---

## 6. Authentication Recommendations

### OAuth-Only Strategy — Good Decision

Not supporting email/password is a strong anti-sharing move. Users can't just
share `login@example.com / password123`. They'd need to share their actual
Google/Facebook account.

### Account Linking (Critical)

When a user logs in with Facebook and their email matches an existing Google
user, you need a strategy:

- **Option A (recommended):** Link accounts via an `OauthIdentity` model.
  Store multiple provider/uid pairs per user. On login, first look up by
  provider+uid; if not found, look up by email and link.
- **Option B (simpler):** Reject and tell them to use Google. Worse UX but
  simpler code.

**Recommended `OauthIdentity` model:**

```
OauthIdentity
  - user_id (references users)
  - provider (string)
  - uid (string)
  - email (string)
  - auth_data (jsonb, optional — store raw OAuth hash)
  - unique index on (provider, uid)
```

### Facebook App Review

To go live with Facebook Login, the app must be submitted for review. This
takes days to weeks. Start the process early. Required permissions: `email`,
`public_profile`.

### Apple Sign In

The developer fee is $99/year. Worth it if the audience uses iPhones — Apple
users on Safari get a much smoother experience. For the Czech market,
Google + Facebook covers 90%+. Defer to post-MVP.

### Session Management

```
UserSession model:
  - user_id
  - session_token (unique)
  - ip_address
  - user_agent
  - last_active_at
  - created_at
```

- Show active sessions in user settings.
- Allow "log out everywhere."
- Limit to 2-3 concurrent sessions.
- Set own session expiry (e.g., 30 days) and force re-authentication via
  OAuth after that. With OAuth, you don't control the session length — set
  your own.

---

## 7. Payment & Business Logic

### Stripe Best Practices

1. **Store `stripe_customer_id` on User.**
   Create a Stripe customer on first purchase, reuse it. Enables:
   - Refunds.
   - Customer portal.
   - Future subscriptions.
   - Better analytics in Stripe dashboard.

2. **Handle more webhook events:**
   - `charge.refunded` — revoke enrollment, update order status.
   - `checkout.session.expired` — mark order as canceled, clean up.
   - `payment_intent.payment_failed` — for async payment methods.

3. **Idempotency.**
   Use `stripe_session_id` as the idempotency key. Before processing a
   webhook, check: "Is this order already paid?" If yes, return 200 and skip.

4. **Webhook processing should be async.**
   Move to a Sidekiq job. The webhook endpoint should validate signature,
   enqueue job, return 200 immediately. Prevents timeouts.

### Fakturoid (Czech Legal Compliance)

This is **not optional** for selling in CZ:
- ICO/DIC fields (company ID / VAT ID) needed on order or billing profile.
- Proper invoice with sequential numbering.
- Invoice must be issued within 15 days of payment.
- VAT handling if the seller is a VAT payer.

**Collect billing details during checkout** (optional fields — individuals
don't need company details, but many Czech customers want to purchase as
a company).

### Coupon System Improvements

The current coupon system is solid. Consider adding:
- **Per-course coupons** (currently coupons are order-level only).
- **First-purchase-only coupons** (check if user has any previous orders).
- **Minimum order amount** threshold.
- **Usage tracking dashboard** in admin (redemption count, revenue impact).

---

## 8. Architecture & Code Quality

### Issues Found

1. **No service objects.**
   Business logic (checkout flow, enrollment creation, coupon application)
   lives in controllers. Extract to:
   - `CheckoutService` — creates order, builds Stripe session.
   - `EnrollmentService` — creates enrollments from paid order.
   - `CouponService` — validates and applies coupons.
   - `WebhookProcessorService` — handles Stripe events.

2. **No Procfile.**
   Needed for Heroku deployment with Sidekiq:
   ```
   web: bundle exec puma -C config/puma.rb
   worker: bundle exec sidekiq
   ```

3. **No `bin/setup` script.**
   Makes onboarding harder for collaborators.

4. **Tests are stubs.**
   Model tests exist but appear minimal. Before launch, test at minimum:
   - Checkout flow (integration).
   - Webhook processing (unit).
   - Enrollment / access control (integration).
   - Coupon calculation (unit).
   - Mandatory chapter locking (unit).

5. **No CI/CD.**
   No GitHub Actions workflow. Add at minimum: `bin/rails test`, Brakeman,
   bundler-audit.

---

## 9. Recommendations from Similar Platforms

Based on Teachable, Thinkific, Udemy, Kajabi patterns.

### UX Features Worth Adding

1. **Free preview segments.**
   Let non-logged-in users watch 1-2 segments for free. This is the #1
   conversion driver for course platforms. Add `is_free_preview` (boolean)
   to Segment.

2. **Course bundles.**
   Sell multiple courses at a discount. A `Bundle` model with
   `has_many :courses, through: :bundle_items` and a single price.

3. **Certificate of completion.**
   Generate a PDF certificate when a user completes all mandatory chapters.
   Big motivator. Can be simple — a branded PDF with user name, course name,
   date.

4. **Email marketing integration.**
   After purchase, add user to a mailing list. Czech market uses Ecomail
   heavily. Mailchimp is also an option.

5. **Course ratings/reviews.**
   Social proof drives sales. Even a simple 1-5 stars + comment per enrolled
   user.

6. **"Continue watching" on homepage.**
   Show the user's last-accessed course with a resume button. `CourseProgress`
   already exists — just surface it.

7. **Purchase receipts via email.**
   Even if Fakturoid sends the invoice, send a friendly "Thanks for your
   purchase" email with a course access link.

### SEO (Czech Market)

- **Hreflang tags** if cs + en is planned.
- **Structured data** (Course schema from schema.org) — Google shows rich
  snippets for courses.
- **OG tags** for social sharing (course cover image, description).
- **Sitemap** for public course pages.

### Monetization Ideas (Post-MVP)

- **Subscriptions** — monthly/yearly access to all courses (use Stripe
  Billing, possibly the `pay` gem).
- **Upsell / cross-sell** — "Users who bought this also bought..." on the
  course page and checkout success page.
- **Affiliate program** — let users share referral links for a commission.
- **Time-limited access** — some platforms sell 6-month or 1-year access
  instead of lifetime. Add `expires_at` to Enrollment.

---

## 10. Priority Summary

### Before Launch (Must Do)

| # | Item | Effort | Status |
|---|------|--------|--------|
| 1 | Add Pundit for authorization | Medium | DONE |
| 2 | Add `rack-attack` for rate limiting | Small | TODO |
| 3 | Add `status` + `revoked_at` to Enrollment | Small | DONE |
| 4 | Add `stripe_customer_id` to User | Small | DONE |
| 5 | Handle additional Stripe webhook events + idempotency | Medium | DONE |
| 6 | Add purchase confirmation mailer | Medium | DONE |
| 7 | Add good_job + move webhooks to background jobs | Medium | DONE |
| 8 | Add error monitoring (Sentry) | Small | TODO |
| 9 | Add billing details collection (BillingProfile model) | Medium | TODO |
| 10 | Switch dev/test to PostgreSQL | Small | DONE |
| 11 | Add account linking strategy for OAuth providers | Medium | DONE |
| 12 | Real content for legal pages (terms, privacy, GDPR) | Medium | DONE |
| 13 | Add `title_snapshot` to OrderItem | Small | DONE |

### Post-MVP (High Impact)

| # | Item | Effort | Status |
|---|------|--------|--------|
| 1 | HLS streaming with video.js + Cloudflare Worker | Large | TODO |
| 2 | Dynamic watermark on videos | Medium | TODO |
| 3 | Session concurrency limits | Medium | DONE |
| 4 | Free preview segments (`is_free_preview` on Segment) | Small | DONE |
| 5 | Fakturoid integration | Large | TODO |
| 6 | Course bundles | Medium | TODO |
| 7 | Certificate of completion (PDF) | Medium | TODO |
| 8 | Email marketing integration (Ecomail) | Medium | TODO |
| 9 | Course tags / categories | Small | TODO |
| 10 | Course ratings / reviews | Medium | TODO |
| 11 | Gifted courses flow | Medium | TODO |
| 12 | SEO (structured data, sitemap, OG tags) | Small | DONE |
| 13 | CI/CD (GitHub Actions) | Small | TODO |
| 14 | Dark mode (day/night/system toggle in navbar, works for both admin and user) | Medium | TODO |
