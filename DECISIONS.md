# AACollectibles — Decisions

Decision log for how the site is built and what it runs on. Newest context at the top of
each entry. `NOTES.md` is the to-do list; this file is the *why*.

Each entry is one of:

- **Decided** — settled, build against it
- **Provisional** — the working assumption, cheap to reverse, not locked
- **Open** — needs a call before the work can start
- **Deferred** — deliberately parked, with the trigger to revisit

---

## Background: what "a backend" has to do here

Four separate jobs, which is why there isn't one single answer:

1. **Product & inventory** — what's in stock, its condition, its price
2. **Checkout & payments** — card processing, tax, shipping rates, PCI compliance
3. **Order operations** — packing slips, labels, tracking, refunds
4. **Buylist** — buying collections from customers

Jobs 1–3 are commodity problems that a hosted platform solves better than we would.
Job 4 is the one with no good off-the-shelf answer at our size.

The site as it stands today is five static HTML pages sharing one stylesheet, with no
server behind it. It deliberately cannot take an order: the prop cart was removed and
the pages route to TCGplayer, Instagram and the shows page instead (see NOTES.md,
*Before Shopify*). Whichever path below we take restores a real cart from the theme.

---

## 001 — Shopify as the commerce backend

**Status: Provisional** · 11 Sep 2026

Shopify is the system of record for products, inventory, orders and payments.

**Why:** payments, tax calculation, shipping rates and PCI compliance are not worth
owning for a shop this size, and the failure modes of getting them wrong are expensive.
Shopify covers jobs 1–3 in one place and is already the preferred option.

**Not locked because** the storefront approach (002) is still open, and a trading-card
platform (see *Alternatives*) could displace it if inventory upkeep turns out to be the
dominant cost.

---

## 002 — Storefront: Shopify theme or static + Storefront API

**Status: Open** · recommendation below

Two ways to attach the current design to Shopify:

**A. Port the design into a Shopify theme** *(recommended)*
Shopify hosts the site; the design becomes Liquid templates. The CSS transfers
essentially unchanged, the listing card becomes a snippet, the category pages become
collection templates, and the filter chips map onto Shopify's native filtering.

- Gets us for free: search, pagination, customer accounts, order status, discount
  codes, email receipts, checkout
- Costs us: a port, and the design now lives in Shopify rather than in this repo

**B. Keep the static site, pull products via the Storefront API**
The current files stay as they are, hosted free on Cloudflare Pages or Netlify, with
products fetched client-side.

- Gets us: the repo stays the source of truth, total control of the markup
- Costs us: hand-building search, filtering, pagination and cart persistence — all of
  which A provides at no cost

**Recommendation: A.** With roughly 9,500 listings, B means rebuilding commodity
features that A includes. Headless earns its keep at larger scale or with a team; for
two people it is mostly self-inflicted work.

Shopify's Buy Buttons were considered as a third option and rejected — they suit a
dozen products, not thousands.

### What porting actually involves

There is no path where the static HTML files get uploaded to Shopify. A theme is a fixed
directory structure written in Liquid, and products come out of Shopify's database
through template loops. Hardcoded listing markup is invisible to Shopify — it isn't a
product, so it can't be bought, counted or filtered.

What survives the port:

| Asset | Transfers? |
| --- | --- |
| `styles.css` | **Almost verbatim.** It has zero `url()` references — every graphic is a gradient or inline SVG — so there are no asset paths to rewrite |
| `Logo.png` | Yes |
| Copy and page structure | Yes |
| `main.js` — theme toggle, drawer, counter strip | Yes, unchanged |
| `main.js` — cart | **No.** Replaced by Shopify's AJAX Cart API |
| The 33 hardcoded listings | **No.** They become products in the admin |
| The three category pages | **No.** They collapse into one collection template |
| Filter chips | **No.** Rewired to Shopify's server-side filtering |

Effort: roughly 2–4 days for someone comfortable in Liquid, a week or two while
learning it.

**A scaffold now exists at `theme/`** — layout, header/footer, the six homepage
sections, collection, product, cart and search templates, and the product-card snippet,
with the stylesheet wired in. See `theme/README.md` for how to push it and what is
deliberately missing.

**Starting point: a purpose-built minimal theme, not Dawn.** Dawn was the initial
instinct, on the reasoning that it brings working cart, search and accounts. Rejected
once the specifics were checked: our CSS is complete and self-contained and written
against our own class names, so Dawn's own stylesheet and markup would mostly be code to
delete — and the two things Dawn would genuinely have saved us, checkout and the new
customer accounts, are hosted by Shopify outside the theme anyway.

**The prototype in the repo root stays.** It is the design reference the port is checked
against, and the stylesheet is literally shared with it — see the note in
`theme/README.md` about not letting the two copies drift.

---

## 003 — Physical counter and POS

**Status: Deferred** · 11 Sep 2026

Not building for in-person selling yet.

**Why:** there may be a physical counter later, but it isn't happening now, and
designing around it would drive the whole stack choice prematurely.

**Revisit when in-person selling becomes real.** It is the single biggest input to this
decision — selling in two channels off one stock pool makes POS integration the
deciding factor rather than a feature, and it would put Shopify POS or a card-shop
platform well ahead of anything else. Reopen 001 and 002 at that point.

Done: the footer no longer advertises walk-in hours. It now reads online, plus in
person at a show most weekends.

---

## 004 — Buylist: an email form

**Status: Decided** · 11 Sep 2026

The sell-to-us page collects submissions and emails them to us. No portal, no account,
no status tracking, no automated quoting.

**Why:** Shopify has no native buylist, and the purpose-built options all arrive
attached to a whole platform. Volume is low enough that a human reading an inbox is
genuinely the right tool, and it does not block launch.

**What it needs:** contact details, a description of the cards or collection, an asking
price, and photo upload. It should handle single cards and whole collections alike.

**Implementation:** a form service rather than a server of our own — Shopify Forms if
we're on Shopify, otherwise Formspree or Netlify Forms. Photo upload is the constraint
that will decide which; check the file-size limits on the free tiers before committing.

See `NOTES.md` for the build checklist.

---

## 005 — Getting inventory in, and keeping it priced

**Status: Open** · this is the real risk

Checkout is the easy part. Card inventory is the awkward part: thousands of SKUs, most
at quantity 1, the same card existing at several conditions and two languages at
different prices, and prices that drift with the market.

Shopify's data model handles this — product = the card printing, options = Condition /
Language / Finish, which is exactly its three-option limit. Quantity-1 stock is fine.

The unsolved parts:

- **Bulk import.** Nobody is typing 9,500 listings into an admin. Plan on CSV import or
  Matrixify from day one.
- **Repricing.** Needs a scheduled script against a price source.
- **Price source.** TCGplayer's API requires approval. **Confirm access early** — this
  is the item most likely to stall the whole project, and it has a lead time we don't
  control.

---

## Alternatives considered

**Trading-card platforms — BinderPOS, Crystal Commerce, TCGplayer Pro.**
Worth an hour of evaluation before committing to 002. They solve inventory, pricing and
buylist out of the box, and BinderPOS is Shopify-native.

The tension is real and worth stating plainly: **these tools and a bespoke design pull
against each other.** They bring their own storefront assumptions. A custom theme keeps
the design and leaves us owning the inventory tooling; a card platform solves inventory
and constrains the design.

Leaning custom theme, given how much the current design has been iterated on — but
revisit if manual inventory upkeep becomes the thing that hurts.

**Snipcart.** Turns static HTML into a store with data attributes, so the current files
survive untouched. Rejected because inventory and order operations stay ours.

**Stripe Checkout plus our own backend.** Cheapest and most flexible, and the most work
by a distance. No reason to take that on at this size.

**Square Online.** Only becomes interesting if 003 reopens and we're already on Square
hardware at the counter.

---

## Verify before committing

Plans, pricing and ownership in this space change, so treat these as things to check
rather than facts:

- Current Shopify plan pricing and what each tier includes
- BinderPOS's current status — it has changed hands
- TCGplayer API approval process and lead time
- Photo-upload limits on whichever form service we pick (004)

---

## 006 — No live inventory sync

**Status: Decided** · 12 Sep 2026

The showcase is not synced to TCGplayer. Prices are generated at build time and
stamped with the build date; per-card stock counts were removed entirely.

**Why:** three reasons, in order of weight.

1. **It would be thrown away.** Once Shopify is the system of record (001) the theme
   reads inventory from Shopify directly and is live by definition. Anything built
   against TCGplayer now gets deleted then.
2. **The showcase is 33 cards, not 9,500.** The site is a shop window; the catalogue
   lives on the marketplace. Syncing thousands of items to display thirty is
   disproportionate.
3. **A static site can't do it cleanly anyway.** On GitHub Pages there are only three
   options: a browser fetch (blocked by CORS, and the API key would be public), a
   serverless proxy (a backend, with a key to rotate and an endpoint to monitor), or a
   scheduled rebuild. Only the third is reasonable, and without API access it does
   nothing that running the build by hand doesn't.

**What we did instead** — separate data by how fast it moves:

| Changes | Treatment |
| --- | --- |
| Name, set, card number, rarity | Hardcoded. Never goes stale. |
| Price | Shown, with a build date next to it. |
| Stock count | Removed. Aged worst, hurt most. |

More moving parts means more ways to be embarrassing at a show. A dated price reads as
careful; a broken sync showing an empty case does not.

**Revisit if** the owners turn out to have TCGplayer API access *and* Shopify slips a
long way out. Treat API availability as unverified — access has been gated behind
approval and policy shifted after the eBay acquisition.
