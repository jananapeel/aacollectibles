# AACollectibles — Notes

Running list of things to build. For *why* the stack is what it is — Shopify, the
buylist, the storefront approach — see `DECISIONS.md`.

> **This repo is public**, and GitHub Pages serves files from it over HTTP. Keep business
> context — margins, what the owners have or have not supplied, anything you would not
> want a customer or a competitor reading — in `PRIVATE-NOTES.md`, which is gitignored.
> Technical notes belong here.

## Site structure

**The brand is spelled AACollectibles** — with an *i*, matching the logo, settled
12 Sep 2026. Anything reading `aacollectables` is a leftover, not an alternative.

**Casing is a separate matter.** The GitHub repo and its Pages path are lowercase, and
Pages paths *are* case-sensitive even though github.com URLs are not:

```
https://jananapeel.github.io/aacollectibles/      ← live
https://jananapeel.github.io/AACollectibles/      ← 404
```

Use the lowercase URL on anything printed, linked or turned into a QR code.

Two things live here:

- **The repo root** — the static prototype. No build step, no dependencies; open any
  page directly in a browser. This is the design reference.
- **`theme/`** — the Shopify theme scaffold that carries the same design. See
  `theme/README.md`.

`theme/assets/styles.css` is the root `styles.css` plus a Shopify-only block appended at
the end. Don't edit it directly — edit the root file and re-run the build, which
re-appends the block for you.

### Regenerating

The five static HTML pages and `theme/assets/styles.css` are **generated**. Don't
hand-edit them; edit the sources and run:

```
pwsh build/build.ps1              # regenerate the pages + theme stylesheet
pwsh build/build.ps1 -Preview     # also emit build/preview.html, one shareable file
```

| Edit this | To change |
| --- | --- |
| `styles.css` (root) | Anything visual, in both the prototype and the theme |
| `main.js` (root) | Prototype behaviour |
| `build/parts/nav.html`, `foot.html` | Header and footer — shared by every page |
| `build/parts/home.html` etc. | One page's content |
| `build/parts/shows.html` | The show schedule (hand-written rows, not generated) |
| `build/build.ps1` | The placeholder listings (the catalogue near the top) |
| `build/shopify-additions.css` | Styles that only the Shopify theme needs |

`theme/` is hand-maintained apart from its stylesheet — the build never touches the
Liquid.

### The static prototype

| File | Page |
| --- | --- |
| `index.html` | Homepage |
| `pokemon.html` | Pokémon TCG |
| `one-piece.html` | One Piece Card Game |
| `riftbound.html` | Riftbound |
| `shows.html` | Weekend card-show schedule |
| `styles.css` | All styling, shared by every page |
| `main.js` | Cart, toast, counter strip, filters, nav state, show dates |
| `Logo.png` | Brand mark — also the favicon |

Every page pulls in the same `styles.css` and `main.js`, so a change to either lands
everywhere at once. The header and footer markup is copied into each generated page by the build, so edit
`build/parts/nav.html` or `foot.html` once and rebuild.

The colour palette in `styles.css` is sampled directly from `Logo.png`
(`--void: #0D1014`, `--gold-fill: #F3DD48`). Keep them matched — the logo's own
background is that exact `--void`, which is why the PNG sits on the dark page with no
visible edge. In light mode it reads as a deliberate dark tile instead (that's the
`border-radius` on `.brand img, .crest`).

### Two golds — use the right one

Dark mode is the default; light mode overrides the tokens. Bright gold is unreadable on
a light background, so gold is split in two and they are **not** interchangeable:

- `--gold` is **gold as ink** — text, labels, rules, borders. It darkens to `#7E6206`
  in light mode so it stays legible.
- `--gold-fill` is **gold as paint** — button and chip backgrounds, the cart badge,
  the toast. It never changes, and always has `--on-gold` text on top of it.

Using `--gold` where you meant `--gold-fill` gives you a muddy brown button in light
mode; the reverse gives you unreadable yellow text on paper.

The display case on the homepage (`.case`) deliberately stays dark in both themes — it's
a lit vitrine. It re-declares the dark tokens locally, so anything nested inside it
inherits dark styling automatically.

The theme choice is saved to `localStorage` under `aac-theme`, and a small inline script
in each page's `<head>` applies it before first paint to avoid a flash. With no saved
choice the site follows the operating system.

## Before Shopify: the site cannot take an order

The cart was removed on purpose. Until checkout is live, every route on the site leads
somewhere that actually works:

- A **status band** under the header on every page says ordering direct is coming, and
  links to TCGplayer, Instagram and the shows page.
- The homepage **`#buy` section** lays out the three real routes, with the direct one
  led visually. It needs no backend.
- Listings are a **showcase**: name, set and a dated price. No buy button, no stock
  count — see *Data freshness* below.
- Set tables are plain rows, not links.

**The day Shopify checkout goes live**, delete: the `.status-band` markup in
`build/parts/nav.html`, the `#buy` section in `build/parts/home.html`, and the
`PRE-SHOPIFY BUYING STATE` block at the end of `styles.css`. Then restore the cart from
the theme, not from git history — `theme/assets/main.js` already has the real one.

### Live links

| Where | URL |
| --- | --- |
| Instagram | `https://www.instagram.com/aa.collectibles_` |
| TCGplayer | `https://www.tcgplayer.com/sellers/Allen-Collects/a0652519` |
| eBay | **not supplied yet** — see the TODO in `build/parts/foot.html` |

Link-in-bio (`refs.me/aa_collectibles`) is deliberately **not** on the site. It points
back at these same destinations, so linking to it from here just adds a hop — and its
URL carries `utm_source=ig&utm_medium=social&utm_content=link_in_bio`, which would
misreport website clicks as Instagram bio clicks. If you do want it on the site, strip
those parameters first.

### Data freshness

The showcase is generated, so a price is only true as of the last build — the pages say
so rather than implying live data. Three deliberate choices:

- **Per-card stock counts were removed.** They aged worst and hurt most: "1 in stock"
  on a card that sold last week is the one error a customer can catch you in.
- **Prices carry a build date**, stamped by `build.ps1` under each grid, next to a link
  to TCGplayer for the live number.
- **The pulsing "live" dot** came off the display case. It implied a feed that does not
  exist.

Re-running the build re-stamps the date, so refreshing prices is: edit the catalogue,
rebuild, commit. Deliberately not synced — see the reasoning in `DECISIONS.md` 006.

### Filling in listings

Two options once the CSV lands:

1. Paste rows into the catalogue near the top of `build/build.ps1` and rebuild.
2. Better: point the build at `build/inventory.csv` so a fresh export regenerates the
   pages. Proposed columns, to be adjusted to whatever TCGplayer actually exports:

   ```
   game,title,set,code,rarity,condition,price,stock,group,kind
   ```

   `group` drives the filter chips (era / set range / domain), `kind` is
   raw / graded / sealed, and the tile colour derives from game and rarity.

**Do not use TCGplayer product images.** Beyond the hotlinking and copyright problems,
the grading section promises "No stock images, ever: the card in the listing photo is
the exact card that ships" — stock photography would contradict that on the same site.

## To build

### Buy-from-customers page (submit an offer)
Add a page where customers can sell their cards to us by submitting an offer.

- Customer submits what they have and the price they want for it.
- Needs at minimum: contact details, card/collection description, asking price, photo upload.
- Should handle both single cards and whole collections/binders/bulk.
- The **"Get a quote"** button in the *Got a binder collecting dust?* section of the homepage
  should link here — it currently goes nowhere.
- The `Sell to us` links in the header nav, the mobile menu and the footer should point
  here too.
- **Submissions go out by email** — a form service (Shopify Forms, Formspree or Netlify
  Forms), not a server of ours. No portal, no account, no status tracking. Decided;
  see `DECISIONS.md` 004.
- Photo upload is the thing that decides which form service — check file-size limits on
  the free tiers before picking one.

### Wire up the filters and links for real
The category-page filter chips work client-side on the listings already on the page.
Once there's real inventory they'll need to filter a real catalogue instead. Also still
pointing nowhere: the "Browse by set" rows (`href="#"`), search, and the cart.

## Open questions

- **Content is still placeholder.** Two visible markers say so — the `tag` in the footer
  and the "Sample schedule" tag on the shows page. Both come off together, once, when
  real data lands. Until then leave them up. Details in `PRIVATE-NOTES.md`.

### How the show dates work

Show rows carry `data-show-date="YYYY-MM-DD"`, and `main.js` dims anything in the past
and writes the relative label on the next-show panel ("This Saturday", "In 3 weeks").
Nothing relative is hardcoded in the HTML, so a stale page degrades to plain dates
rather than lying about what weekend it is. Two consequences:

- Adding a show means one row plus the right `data-show-date`. Keep the visible date
  and the attribute in sync — nothing checks them against each other.
- Past shows dim but stay on the page. Prune them by hand when the list gets long.
