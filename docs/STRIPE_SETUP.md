# Stripe Checkout Setup

## Environment variables

Set these in your environment (Heroku config vars or `.env`):

- `STRIPE_SECRET_KEY` (required)
- `STRIPE_WEBHOOK_SECRET` (required for signature verification)

## Webhook endpoint

Create a webhook in Stripe Dashboard pointing to:

`POST /webhooks/stripe`

Listen for at least:

- `checkout.session.completed`

## Behavior

- We create a pending Order before redirecting to Stripe Checkout.
- On `checkout.session.completed`, the Order is marked paid, Enrollments are created, and the cart is cleared.
- The success page is just a friendly message; the webhook is the source of truth.

