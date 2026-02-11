# Security Audit

**Date:** 2026-02-11
**Scope:** Authentication, session management, authorization, rate limiting, CSP.

---

## 1. Admin Authentication (Devise)

| Feature | Status |
|---------|--------|
| Password-based auth (bcrypt, 12 stretches) | Enabled |
| Login via username or email | Enabled |
| Case-insensitive keys | Enabled |
| Account lockout after failed attempts (`:lockable`) | Enabled — 5 attempts, auto-unlock after 1 hour |
| Session timeout on inactivity (`:timeoutable`) | Enabled — 30 minutes |
| Password reset (`:recoverable`) | Enabled — token expires in 6 hours |
| Remember-me (`:rememberable`) | Enabled — invalidated on sign-out |
| Rate limiting on login | 5 requests/min per IP (Rack::Attack) |
| Rate limiting on password reset | 5 requests/min per IP (Rack::Attack) |

### Devise modules on Admin

```ruby
devise :database_authenticatable,
       :recoverable, :rememberable, :validatable,
       :lockable, :timeoutable,
       authentication_keys: [:login]
```

---

## 2. User Authentication (OAuth-only)

Users authenticate exclusively via Google or Facebook OAuth. No passwords stored.

| Feature | Status |
|---------|--------|
| Google OAuth2 (email + profile) | Enabled |
| Facebook OAuth (email + public_profile) | Enabled |
| CSRF on OAuth requests | Enabled (omniauth-rails_csrf_protection, POST-only) |
| Account linking via OauthIdentity | Enabled — links by email across providers |
| Rate limiting on OAuth callbacks | 20 requests/min per IP |

### Account linking strategy

1. Look up `OauthIdentity` by `(provider, uid)` — return existing user.
2. Look up `User` by email — link new identity to existing user.
3. Create new user + identity if neither found.

**Risk:** If an attacker controls an OAuth account with the target's email, they
gain access. Mitigated by the fact that Google and Facebook both verify emails.

---

## 3. Session Management

### Admin sessions

- Managed by Devise with cookie-based storage.
- `:timeoutable` enforces 30-minute inactivity timeout.
- Remember-me tokens invalidated on sign-out.

### User sessions

- Tracked via `UserSession` model (session_token, ip_address, user_agent, last_active_at).
- 256-bit secure tokens (`SecureRandom.urlsafe_base64(32)`).
- Max 2 concurrent sessions per user (enforced on login).
- Session max lifetime: 30 days (enforced in `validate_session`).
- Activity timestamp updated every 5 minutes.
- Invalid/expired sessions immediately cleared and redirected to login.

---

## 4. Rate Limiting (Rack::Attack)

| Endpoint | Limit | Period |
|----------|-------|--------|
| Admin login (`POST /admin/login`) | 5 | 1 min |
| Admin password reset (`POST /admin/password`) | 5 | 1 min |
| OAuth callbacks (`/auth/*/callback`) | 20 | 1 min |
| Checkout (`POST /checkout`) | 10 | 1 min |
| Coupon apply (`PATCH /cart/apply_coupon`) | 5 | 1 min |
| Cart operations (`POST /cart_items`) | 30 | 1 min |
| Stripe webhook (`POST /webhooks/stripe`) | 100 | 1 min |
| User settings (`PATCH /user/settings`) | 10 | 1 min |
| Account deletion (`DELETE /user/settings`) | 2 | 1 min |
| Global | 300 | 1 min |

---

## 5. Authorization (Pundit)

- All controllers enforce `after_action :verify_authorized` (except Devise).
- Admin area requires `authenticate_admin!` via `AdminArea::BaseController`.
- User area requires `require_user!` via `UserArea::BaseController`.
- Policy objects for all models (`AdminPolicy`, `CoursePolicy`, `OrderPolicy`, etc.).

---

## 6. CSRF Protection

- Rails default CSRF enabled on all controllers.
- `StripeWebhooksController` skips CSRF — uses Stripe signature verification instead.
- OmniAuth: `omniauth-rails_csrf_protection` gem enforces CSRF on OAuth request phase.

---

## 7. Content Security Policy

Enforced (not report-only) with the following directives:

| Directive | Value |
|-----------|-------|
| `default-src` | `'self' https:` |
| `script-src` | `'self' https:` + nonce |
| `style-src` | `'self' https: 'unsafe-inline'` (needed for Tailwind) |
| `img-src` | `'self' https: data: blob:` |
| `media-src` | `'self' blob: https:` |
| `object-src` | `'none'` |
| `frame-src` | `checkout.stripe.com js.stripe.com` |
| `frame-ancestors` | `'none'` (clickjacking protection) |
| `form-action` | `'self' checkout.stripe.com` |
| `base-uri` | `'self'` |

Nonce applied to `script-src` for inline script tags.

---

## 8. Transport Security

- `config.force_ssl = true` in production.
- All cookies are Secure + HttpOnly + SameSite=Strict (Rails 8.1 defaults).
- HSTS headers automatically set by `force_ssl`.

---

## 9. Webhook Security

- Stripe webhook signature verified via `Stripe::Webhook.construct_event`.
- Returns 400 on invalid signature.
- Controller inherits from `ActionController::Base` (not ApplicationController) — isolated.
- Idempotency: checks `order.paid?` before processing to prevent duplicate enrollments.

---

## 10. Known Limitations / Future Improvements

| Item | Priority | Notes |
|------|----------|-------|
| `style-src 'unsafe-inline'` in CSP | Low | Required for Tailwind — no practical workaround |
| CSP nonce uses `session.id` | Low | Per-request nonce would be stronger but adds complexity |
| Email-based OAuth account linking | Low | Risk mitigated by provider email verification |
| No admin audit logging | Medium | `AuditLog` model planned but not yet implemented |
| No user data export (GDPR) | Medium | Account deletion exists but not export |
