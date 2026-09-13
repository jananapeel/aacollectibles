# AACollectibles — Shopify theme

A minimal, purpose-built theme carrying the design from the static prototype in the repo
root. It is a **skeleton, not a finished store** — see *Not built yet* below.

## Push it

```bash
npm install -g @shopify/cli @shopify/theme
cd theme
shopify theme dev --store your-store.myshopify.com   # local preview, hot reload
shopify theme push --unpublished                     # upload as a draft
```

`shopify theme dev` runs against your real products, so add two or three before you look
at it — an empty store makes every template look broken.

## What maps to what

| Static prototype | Theme |
| --- | --- |
| `index.html` | `templates/index.json` + the six homepage sections |
| `pokemon.html`, `one-piece.html`, `riftbound.html` | **One** `templates/collection.json` — the three become Shopify collections |
| `<article class="listing">` × 33 | `snippets/product-card.liquid`, fed by a product loop |
| Filter chips (client-side JS) | `collection.filters` — server-side, from the Search & Discovery app |
| `styles.css` | `assets/styles.css` — the prototype file plus a Shopify-only block at the end |
| `main.js` cart (a prop) | Shopify AJAX Cart API in `assets/main.js` |

**The stylesheet is shared.** Everything above the `SHOPIFY THEME ADDITIONS` banner in
`assets/styles.css` is byte-identical to the root `styles.css`. Keep it that way — make
design changes in the root file and re-append, so the prototype and the theme can't drift.

## Setting up the store to match

1. **Collections** — make one per game (`pokemon`, `one-piece`, `riftbound`). Point the
   Game panels section at them in the theme editor.
2. **Menus** — `main-menu` for the header and drawer, `footer` for the footer columns.
3. **Filters** — install Shopify's free **Search & Discovery** app and add filters for
   Condition, Language and Finish. Without it, `collection.filters` is empty and the
   filter bar simply doesn't render.
4. **Logo** — upload `Logo.png` in theme settings. Do **not** crop it to a transparent
   PNG: its background is `#0D1014`, exactly the dark theme's `--void`, which is why it
   sits on the page with no visible edge.

## How products should be structured

The card snippet reads these, all with fallbacks, so nothing breaks if you skip one:

| Field | Used for | Example |
| --- | --- | --- |
| Title | Listing name | `Umbreon VMAX — Alt Art` |
| Vendor | Game badge on the card face | `Pokémon` |
| Type | The set line under the title | `Evolving Skies · 215/203 · EN` |
| Tag `rarity:SIR` | Gold rarity badge | `rarity:SIR` |
| Tag `face:night` | Which drawn card face to use when there is no photo | `face:ember` |
| Variants | The condition pill and price | `PSA 10 Gem Mint`, `Near Mint`, `Sealed` |

Use **variant options** for Condition / Language / Finish — three options is Shopify's
limit and exactly what cards need. One product per card printing, one variant per
condition, quantity 1 where that's the truth.

Face values available: `night`, `ember`, `crim`, `deep`, `jade`, `steel`, `volt`, `rune`,
`sun`. They only show when a product has no image, so they're a stopgap while you
photograph stock — not a substitute for it.

Optional metafields the hero display case looks for: `custom.grade`, `custom.grade_label`,
`custom.cert`, `custom.card_number`.

## Not built yet

Deliberately out of scope for a skeleton — add as you need them:

- Customer account templates (Shopify's new customer accounts are hosted, so you may
  never need these)
- Predictive search dropdown — `templates/search.liquid` is a normal results page
- A cart drawer — adding goes through AJAX and updates the header count, but sends you
  to `/cart` to check out
- `templates/blog.liquid`, `article.liquid`, `list-collections.liquid`
- The buylist page (`DECISIONS.md` 004) — a Shopify page plus a form app
- A shows template. The prototype has `shows.html` with the weekend card-show schedule;
  it has no Shopify equivalent yet. It is static content, so a `page.shows` template
  with a section carrying the rows as blocks would do it.

## Known rough edges

- The homepage `index.json` ships with the prototype's **placeholder copy and figures**.
  Every number in it is placeholder. Edit in the theme editor before launching.
- The footer's `note` setting still carries the demo-content warning. Clear it.
- Counter hours are in the footer section settings. Remove unless a walk-in counter is
  real (`DECISIONS.md` 003).
- No theme-check run yet. Run `shopify theme check` before you publish.
