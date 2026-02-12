# Authors

## Overview

Authors represent content creators on the platform. Each course and subscription plan can belong to an author. Authors have public profile pages and appear in the sitemap.

## Model

**Table:** `authors`

| Column       | Type   | Constraints      |
|-------------|--------|------------------|
| first_name  | string | NOT NULL         |
| last_name   | string | NOT NULL         |
| email       | string |                  |
| slug        | string | NOT NULL, UNIQUE |

**Associations:**
- `has_many :courses`
- `has_many :subscription_plans`
- `has_rich_text :bio` (Action Text)
- `has_one_attached :profile_image` (Active Storage, max 10 MB, image types only)

**Slug auto-generation:** If slug is left blank, it is auto-generated from `"#{first_name} #{last_name}".parameterize` before validation (e.g. "Jan Novák" → `jan-novak`).

## Admin area

**URL:** `/admin/authors`

Full CRUD with profile image upload (drag-and-drop dropzone). Accessible from the admin navigation bar under "Autoři".

**Actions:**
- Index — list all authors with avatars
- New / Edit — form with first name, last name, email, slug, bio (rich text), profile image
- Show — detail page with bio, linked courses list
- Delete profile image — separate action

## Public profile

**URL:** `/autori/:slug`

Displays author bio, profile image, and grids of their public courses and subscription plans.

## Courses integration

Courses have an optional `belongs_to :author`. The author dropdown appears in the admin course form when at least one author exists. The `author_id` field is nullable — existing courses without an author continue to work.

## Sitemap

Authors with at least one public course are included in `/sitemap.xml` with priority 0.7.
