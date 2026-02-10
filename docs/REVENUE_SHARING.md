# Revenue Sharing Model for Course Reselling

Guidelines for reselling third-party video training courses on the platform.

**Date:** 2026-02-10

---

## Revenue Share Models

### 1. Fixed Percentage Split (recommended to start)

| Split (Creator / Platform) | When to use |
|----------------------------|-------------|
| **80/20** | Default — attracts quality creators, fair for a new platform |
| 70/30 | Industry standard (Udemy, Gumroad) — use once platform has strong organic traffic |
| 50/50 | Platform handles all marketing, support, and customer acquisition |

### 2. Tiered by Volume

| Monthly sales | Creator share | Platform share |
|---------------|---------------|----------------|
| 0 -- 50       | 70%           | 30%            |
| 51 -- 200     | 75%           | 25%            |
| 200+          | 80%           | 20%            |

Motivates both sides to grow. Tiers reset monthly.

### 3. Split by Traffic Source

| Who brought the customer? | Creator share | Platform share |
|---------------------------|---------------|----------------|
| Creator's own link / audience | 90% | 10% |
| Platform organic traffic | 60% | 40% |
| Platform paid ads | 50% | 50% |

This is the Udemy model. Creators appreciate the fairness because they keep more when they do the marketing themselves.

---

## Recommended Starting Model

**80/20 (creator gets 80%)** with a simple contract.

Rationale:
- New platform needs content more than margin
- Creators provide the IP — that's the real value
- Platform costs are low (Heroku, Stripe ~1.4%, R2 storage)
- Renegotiate with new creators once traffic grows

---

## Payment Implementation

- **Stripe Connect** — automates split payments and payouts to creators
- Monthly payout cycle with a creator dashboard showing earnings
- Minimum payout threshold: 500 CZK (avoids micro-transfers)
- Creator sets the price, platform approves it
- Revenue share calculated on **net amount** (after Stripe fees, refunds, VAT)

---

## Contract Essentials

| Clause | Detail |
|--------|--------|
| Exclusivity | **Non-exclusive** — creators can sell elsewhere (easier to sign people) |
| Revenue base | Net amount (after Stripe fees, refunds, VAT) |
| Minimum term | 6 -- 12 months (recoups onboarding effort) |
| Promotions | Platform may discount up to 30% with 7 days notice to creator |
| Content rights | Creator retains all IP; platform gets distribution license for term |
| Takedown | Creator can request removal after minimum term with 30 days notice |
| Payout schedule | Monthly, by the 15th of the following month |
| Payout minimum | 500 CZK (rolls over if not met) |

---

## Technical Requirements (future)

To support multi-vendor courses, the platform would need:

1. **Instructor/Creator model** — linked to courses, with payout details
2. **Stripe Connect integration** — for automated split payments
3. **Creator dashboard** — sales, earnings, payout history
4. **Payout tracking** — record of each payout with status
5. **Per-course revenue share override** — different creators may have different terms
6. **Reporting** — monthly statements for creators (PDF export)
