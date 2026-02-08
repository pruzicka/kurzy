# Cloudflare R2 (Active Storage) Setup

This app uses Rails Active Storage with Cloudflare R2 (S3-compatible).

## Buckets

`config/storage.yml` is configured to use a different bucket per environment:

- Development: `kurzy-app-development`
- Production: `kurzy-app-production`

Create both buckets in Cloudflare R2 (private buckets recommended).

## Rails Credentials

Store R2 credentials via:

```sh
bin/rails credentials:edit
```

Add:

```yaml
r2:
  account_id: "..."
  access_key_id: "..."
  secret_access_key: "..."
```

Notes:
- `account_id` is your Cloudflare account ID (used to build the endpoint).
- The endpoint used by the app is:
  `https://<account_id>.r2.cloudflarestorage.com`

## Development: Local vs R2

By default, development uses local disk storage (`:local`) unless R2 credentials are present.

To force R2 in development:

```sh
ACTIVE_STORAGE_SERVICE=r2 bin/dev
```

To force local disk:

```sh
ACTIVE_STORAGE_SERVICE=local bin/dev
```

## CORS (for direct uploads)

Direct uploads from the browser require bucket CORS rules to allow your origins.
At minimum, include:

- `http://localhost:3001` (development)
- `https://kurzy.pohybjezivot.cz` (production custom domain)
- (optional) your Heroku app domain while testing

Also allow the headers Rails uses for direct uploads (e.g. `Content-Type`, `Content-MD5`).

