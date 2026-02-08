# Media Security Notes (R2 + Active Storage)

## What You Have Today

In production you may see URLs like:

`/rails/active_storage/blobs/redirect/<signed_id>/output_720p.mp4?disposition=inline`

That `signed_id` is a *permanent* signed reference to the blob. Anyone who has that URL can fetch the blob (Rails will redirect them to a fresh R2 presigned URL). This is why it is easy to share.

## What We Want (and What’s Realistic)

- We can **not** prevent downloading in an absolute sense. If a browser can play a video, it can be downloaded or screen-recorded.
- We *can* make link sharing much harder by ensuring user-facing HTML never contains permanent Active Storage routes, and by issuing **short-lived** R2 presigned URLs only after server-side authorization.

## Current Implementation

User-facing pages now use auth-gated media endpoints:

- `GET /courses/:course_id/chapters/:chapter_id/segments/:id/video`
- `GET /courses/:course_id/chapters/:chapter_id/segments/:id/cover_image`
- `GET /courses/:course_id/chapters/:chapter_id/segments/:segment_id/attachments/:attachment_id`

These endpoints:

- require a logged-in user session,
- enforce the "mandatory chapter" locking rules,
- redirect to an **R2 presigned URL** with a short expiry (currently `1.hour`),
- set `Cache-Control: no-store` on the redirect response.

See: `app/controllers/segment_media_controller.rb`.

## Remaining Gaps / Possible Upgrades

If you want stronger deterrence than "short-lived URLs + auth gating":

- Add **enrollment checks** (once payments/enrollments exist).
- Use **HLS streaming** (and sign/authorize segment requests).
- Put **Cloudflare Worker** in front of R2 and validate a short-lived token per request.
- Add **dynamic watermarking** (email / order id) to discourage sharing.
