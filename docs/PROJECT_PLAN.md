# Project Plan: Video Course E-Shop

This document outlines the plan for building a new Ruby on Rails application for selling video courses. It covers the project's features, technology stack, data models, and a proposed development timeline.

**Status Legend:**
- [ ] Planned
- [/] In Progress
- [x] Done

---

## 1. High-Level Vision

**Product:** An e-commerce platform specializing in video courses, with downloadable PDF materials.
**Target Audience:** Users seeking to purchase and consume educational video content.
**Monetization:** Direct sales of individual or bundled courses.
**Key Differentiators:** A clean, modern interface for both users and administrators, with a focus on a smooth learning experience. Primary language will be Czech.

---

## 2. Technology Stack & Configuration

A summary of the technical foundation for the application.

| Component             | Technology/Service                                      | Notes & Suggestions                                                                                                                                                             |
| --------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Backend**           | Ruby on Rails 7+                                        | Solid choice. Provides a great foundation with many conventions.                                                                                                                |
| **Interactive UI**    | Hotwire (Turbo) + Stimulus                              | For interactive features (modals, reordering, inline edits, optimistic UI), prefer **Turbo Frames/Streams** + **Stimulus controllers** instead of custom SPA frameworks. |
| **Frontend CSS**      | Tailwind CSS                                            | Excellent for building modern, custom UIs quickly. We should use `tailwindcss-rails`.                                                                                           |
| **Database**          | PostgreSQL                                              | Perfect choice. Robust, scalable, and works seamlessly with Rails.                                                                                                              |
| **Payments**          | Stripe (Checkout + Webhooks)                            | Recommended for v1: use **Stripe Checkout** for one-time payments and build a small, explicit order/enrollment flow around webhooks. We can optionally add the `pay` gem later if we introduce subscriptions or want its customer/billing abstractions. |
| **Invoicing**         | Fakturoid (via API)                                     | Stripe can generate basic invoices, but for Czech accounting compliance, Fakturoid is superior. **Plan:** Use Stripe webhooks. After a `checkout.session.completed` event, a background job will trigger an API call to Fakturoid to create and send the invoice. |
| **Asset Hosting**     | Cloudflare R2 (Active Storage S3 service)               | Use Active Storage's built-in **S3 service** configured to point at R2 (endpoint + access keys). Use a **private bucket** and **short-lived signed URLs** for delivery. |
| **Hosting**           | Heroku                                                  | Heroku is an excellent choice for easy deployment, especially when avoiding Docker-based development initially. It simplifies infrastructure management. |
| **Source Control**    | GitHub                                                  | Standard choice. We'll use GitHub for code hosting and potentially Actions for CI/CD.                                                                                           |
| **Authentication**    | Devise (for Admin) & OmniAuth (for User)                | Devise will handle email/password authentication for administrators. OmniAuth will be primarily used for user sign-up/login via Google/Facebook, enhancing user convenience. |
| **Authorization**     | **Pundit** (Suggestion)                                 | While CanCanCan is classic, **Pundit** is a more modern, lightweight, and object-oriented choice that is often preferred in new Rails apps. It's simpler to reason about.         |
| **Admin Interface**   | Custom (within `/admin` namespace)                      | We will build a custom admin interface to precisely fit our needs, avoiding external dependencies. |
| **Background Jobs**   | Sidekiq                                                 | We'll need this for sending emails, processing payments, and calling the Fakturoid API. Sidekiq is a robust choice, widely used with Rails. |
| **Redis**             | Heroku Redis                                            | Required for Sidekiq. We can also use Redis as a Rails cache store later if needed. |
| **Internationalization**| Rails I18n                                            | Built-in support is strong. We'll structure our `config/locales` with `cs.yml` (default) and `en.yml`.                                                                          |

---

## 3. Core Data Models

This is a preliminary schema. Relationships will be refined during development.

- **User:** (Primarily for OmniAuth logins)
  - `first_name` (string), `last_name` (string), `email` (string, unique)
  - `provider` (string), `uid` (string)
  - `avatar_url` (string, optional)
  - `stripe_customer_id` (string, optional; only if we don't use `pay`)
  - *Associations:* `has_many :enrollments`, `has_many :courses, through: :enrollments`, `has_many :orders`

- **Admin:** (For email/password logins)
  - `email` (string, unique)
  - Devise fields (`encrypted_password`, etc.)
  - *Associations:* None specific, manages application content.

- **Course:**
  - `name` (string), `description` (text), `overview` (rich text)
  - `price` (integer), `currency` (string, default 'CZK')
  - `slug` (string, unique for friendly URLs)
  - `status` (string, e.g., 'draft', 'public', 'archived')
  - `cover_image` (Active Storage attachment, thumbnail)
  - `preview_video_url` (string, optional)
  - *Associations:* `has_many :chapters, -> { order(position: :asc) }`, `has_many :enrollments`

- **Chapter (Kapitola):** (Groups content within a course)
  - `title` (string)
  - `position` (integer, for ordering)
  - `is_mandatory` (boolean, default: false)
  - *Associations:* `belongs_to :course`, `has_many :segments, -> { order(position: :asc) }`

- **Segment:** (A single content unit within a Chapter)
  - `title` (string), `content` (rich text)
  - `position` (integer, for ordering)
  - *Associations:* `belongs_to :chapter`, `has_one_attached :video` (MP4 only), `has_one_attached :cover_image` (thumbnail), `has_many_attached :attachments` (PDF + images, max 10 MB/file)

- **Enrollment:** (Joins a User to a Course they've purchased)
  - `status` (string, e.g., 'active', 'revoked', 'refunded')
  - `revoked_at` (datetime, optional)
  - *Associations:* `belongs_to :user`, `belongs_to :course`, `belongs_to :order`

- **SegmentCompletion:** (Tracks user progress more granularly)
  - `completed_at` (datetime)
  - *Associations:* `belongs_to :user`, `belongs_to :segment`

- **Order:**
  - `status` (string, e.g., 'pending', 'completed', 'failed')
  - `total_cents` (integer)
  - `currency` (string, default 'CZK')
  - `stripe_checkout_session_id` (string, optional)
  - `stripe_payment_intent_id` (string, optional)
  - *Associations:* `belongs_to :user`, `has_many :order_items`

- **OrderItem:**
  - `price` (integer)
  - `currency` (string, default 'CZK')
  - `title_snapshot` (string) (optional but recommended)
  - *Associations:* `belongs_to :order`, `belongs_to :course`

- **Coupon:**
  - `code` (string, unique), `discount_percent` (integer), `expires_at` (datetime)
  - `active` (boolean, default: true)

- **CourseTag / CourseTagging:** (For discovery + recommendations)
  - Tags/categories on courses (simple v1).

- **AuditLog:** (Admin activity tracking; high value for ops)
  - `admin_id`, `action`, `record_type`, `record_id`, `metadata` (jsonb)

---

## 4. Feature Development Plan

### Phase 1: Project Foundation & Setup ([ ] Planned)
- [ ] Initialize new Rails application with PostgreSQL and Tailwind CSS. *(Already done: basic `rails new`.)*
- [ ] Setup Minitest with fixtures for testing.
- [ ] Install and configure Devise for Admin authentication.
    - [ ] Create Admin model with migrations.
    - [ ] Install and configure OmniAuth for User authentication (Google/Facebook).
    - [ ] Create User model with migrations, primarily for OmniAuth details.
    - [ ] Configure Rails I18n for `cs` (default) and `en` locales.
- [ ] Set up basic namespaces and routing for `/admin` and `/user`.
- [ ] Set up Active Storage (R2) and Action Text.
- [ ] Configure Sidekiq + Redis (development + Heroku).
- [ ] Configure mail delivery for transactional emails (purchase confirmation, invoice email, etc.).
- [ ] Add error monitoring (e.g., Sentry) and basic audit logging for admin actions.

### Phase 2: Admin - Course & Content Management ([ ] Planned)
- [ ] Build Admin UI (custom).
- [ ] CRUD for Courses (Draft/Public states).
- [ ] Nested CRUD for Chapters (Kapitoly) within a Course.
  - [ ] Implement drag-and-drop reordering for Chapters (Stimulus + Turbo).
- [ ] Nested CRUD for Segments within a Chapter.
  - [ ] Implement drag-and-drop reordering for Segments (Stimulus + Turbo).
- [ ] Interface to upload/manage videos and PDF/image attachments for Segments (validate type + max 10 MB/file).
- [ ] User management dashboard (view users, enrollments).
- [ ] Sales and order overview.
- [ ] Basic refund/revoke access flow (admin can revoke enrollment, user loses access).

### Phase 3: E-Commerce & Payments ([ ] Planned)
- [ ] Create Course, Order, and Coupon models.
- [ ] Build a shopping cart (`nákupní košík`).
- [ ] Public-facing course "Overview" pages.
- [ ] Implement "Add to Cart" and checkout flow.
- [ ] Integrate Stripe Checkout (one-time payments).
- [ ] Decide whether to add `pay` gem now or later (recommended later unless we need subscriptions soon).
- [ ] Implement Coupon/Discount logic in the checkout.
- [ ] Set up background jobs (Sidekiq) and ensure Redis is provisioned on Heroku.
- [ ] Create webhook endpoint for Stripe events with signature verification and idempotency.
  - [ ] Handle at minimum: `checkout.session.completed`, `checkout.session.async_payment_succeeded`, `checkout.session.expired`, `charge.refunded`.
- [ ] On successful payment webhook, finalize Order + create `Enrollment` records.
- [ ] Implement Fakturoid API call in a background job to generate an invoice.
- [ ] Capture billing details needed for Fakturoid (company/VAT fields as needed for CZ/EU).

### Phase 4: User-Facing Learning Experience ([ ] Planned)
- [ ] `/user` dashboard showing "My Courses".
- [ ] Course consumption interface.
  - [ ] Display Course -> Chapters -> Segments structure.
  - [ ] Video player for Segments.
  - [ ] Download links for attachments.
- [ ] Progress tracking logic.
  - [ ] "Mark as Complete" button for segments/chapters.
  - [ ] Logic to enforce `is_mandatory` chapters (kapitoly).
  - [ ] Visual progress indicators (e.g., 8/10 segments completed).
- [ ] Ensure video delivery is authorized per-enrollment (see "Media authentication strategy" below).

### Phase 5: Polish & Advanced Features ([ ] Planned)
- [ ] Configure OmniAuth providers (Google, Facebook) for User model.
- [ ] Add Facebook login (User).
- [ ] Build a "Recommended Courses" feature (e.g., based on categories or popularity).
- [ ] Refine the UI/UX for both admin and user areas to be beautiful and responsive.
- [ ] Set up CI (GitHub Actions) to run tests and basic linters.
- [ ] Set up deployment to Heroku (GitHub integration or Heroku pipelines).
- [ ] Add SEO basics (sitemap, meta tags, OpenGraph).
- [ ] Add legal pages and consent (Terms, Privacy Policy, Cookies; Czech first).
- [ ] Add analytics (simple pageview + conversion tracking).

---

## 5. Media Authentication Strategy (R2)

Goal: users should not get a permanent, shareable video URL. We can't make this "unshareable" in an absolute sense (screen recording always exists), but we can make link sharing inconvenient and short-lived.

- **Storage:** keep R2 buckets private (no public listing / no public object access).
- **Delivery:** serve videos via **short-lived signed URLs** (e.g., 30-300 seconds) generated only after verifying the user is authorized to access the segment.
- **Avoid permanent Rails blob routes:** do **not** render `/rails/active_storage/blobs/redirect/<signed_id>/...` in user-facing HTML, because the signed id is effectively permanent and shareable.
- **Player flow:** the `<video>` source should point at an auth-gated endpoint that redirects to a short-lived presigned URL.
- **Domain restrictions:** "playable only on some domain" isn't a strong security boundary (Referer headers can be spoofed/omitted). We'll treat this as a nice-to-have only.
- **Optional deterrents (later):** dynamic watermark overlay (e.g., user email/order id), HLS streaming with short-lived signed segment URLs, or Cloudflare Worker token validation in front of R2 for an extra layer.

See `docs/R2_SETUP.md` for bucket + credentials + CORS details.
See `docs/MEDIA_SECURITY.md` for the practical implementation notes and limitations.
See `docs/GOOGLE_AUTH.md` for Google Console redirect URI settings (port `3001` + production domain).
See `docs/FACEBOOK_AUTH.md` for Facebook App settings (OAuth redirect URIs + credentials).
See `docs/STREAMING_PIPELINE.md` for a future HLS encoding + upload plan.

## 6. Suggestions & Improvements

1.  **Authorization (Pundit):** Use Pundit for a cleaner, more scalable authorization system. Policies are just plain Ruby objects and are easier to test and manage than a large `ability.rb` file.
2.  **Rich Text:** For course descriptions and segment content, use `ActionText` with the **Lexxy** editor (instead of Trix) for better writing UX. Keep styling in a dedicated stylesheet so lists/headers render correctly.
3.  **Testing Strategy:** Don't skip testing. We will use Minitest with fixtures. At a minimum, we should have:
    - **Model tests:** For data validations and logic.
    - **System tests:** To simulate user flows like "user buys a course" and "user completes a step". This ensures the application works end-to-end.
4.  **Course Recommendations:** A simple v1 could be "Users who bought this also bought...". A more advanced version could use tags/categories on courses to find related content.
5.  **Operational Must-Haves:** Add admin audit logs, basic refund/revoke access tools, error monitoring, and a backup/restore checklist early. These reduce production pain disproportionately.

---

## 7. Time Estimation (Vibecoding Approach)

This is a rough estimate for a single, experienced Rails developer working full-time. "Vibecoding" can be faster but may incur technical debt if not balanced with good practices.

- **Phase 1 (Foundation):** ~1-2 weeks. Getting the core setup right is crucial.
- **Phase 2 (Admin & Content):** ~3-5 weeks. This is complex, especially with reordering and media uploads.
- **Phase 3 (E-Commerce):** ~2-4 weeks. Integrating payments and invoicing correctly and securely takes time.
- **Phase 4 (User Experience):** ~2-3 weeks.
- **Phase 5 (Polish):** ~1-2 weeks.

**Total Estimated Time: 9 - 16 weeks (approx. 2.5 to 4 months).**

This timeline assumes a clear vision and minimal "unknown unknowns." Real-world development often takes longer. The key to speed will be leveraging Rails conventions and a small number of high-quality gems (e.g., Pundit, Sidekiq) wherever possible.
