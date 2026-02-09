# Facebook OAuth (OmniAuth)

## Credentials

Set in `rails credentials:edit`:

```
facebook:
  app_id: "123456789"
  app_secret: "..."
```

ENV fallback:

- `FACEBOOK_APP_ID`
- `FACEBOOK_APP_SECRET`

## Callback URL

Add in Facebook App > Facebook Login > Settings:

- `http://localhost:3001/auth/facebook/callback`
- `https://kurzy.pohybjezivot.cz/auth/facebook/callback`

## Notes

- Ensure the app is in **Live** mode for production.
- Permissions used: `email`, `public_profile`.

