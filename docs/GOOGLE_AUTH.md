# Google OAuth (OmniAuth)

## Credentials

We read Google OAuth credentials from Rails credentials first, then ENV:

- `Rails.application.credentials.dig(:google, :client_id)`
- `Rails.application.credentials.dig(:google, :client_secret)`
- fallback: `ENV["GOOGLE_CLIENT_ID"]`, `ENV["GOOGLE_CLIENT_SECRET"]`

## Google Console Settings (Web application)

Set these in Google Cloud Console -> OAuth client (type: "Web application"):

Authorized JavaScript origins:

- `http://localhost:3001`
- `https://kurzy.pohybjezivot.cz`

Authorized redirect URIs:

- `http://localhost:3001/auth/google_oauth2/callback`
- `https://kurzy.pohybjezivot.cz/auth/google_oauth2/callback`

Notes:

- The redirect URI must match *exactly* (scheme + host + path). A common mistake is using `http://...` in production instead of `https://...`.
- If you also use the Heroku default domain for testing, add:
  - `https://<your-app>.herokuapp.com/auth/google_oauth2/callback`

