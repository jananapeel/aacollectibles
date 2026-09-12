# AACollectibles — Notes

Running list of things to build. For *why* the stack is what it is — Shopify, the
buylist, the storefront approach — see `DECISIONS.md`.

## Site structure

Two things live here:

- **The repo root** — the static prototype. No build step, no dependencies; open any
  page directly in a browser. This is the design reference.
- **`theme/`** — the Shopify theme scaffold that carries the same design. See
  `theme/README.md`.

`theme/assets/styles.css` is the root `styles.css` plus a Shopify-only block appended at
the end. Don't edit it directly — edit the root file and re-run the build, which
re-appends the block for you.

### Regenerating

The four static HTML pages and `theme/assets/styles.css` are **generated**. Don't
hand-edit them; edit the sources and run:

```
pwsh build/build.ps1              # regenerate the pages + theme stylesheet
pwsh build/build.ps1 -Preview     # also emit build/preview.html, one shareable file
```

| Edit this | To change |
| --- | --- |
| `styles.css` (root) | Anything visual, in both the prototype and the theme |
| `main.js` (root) | Prototype behaviour |
| `build/parts/nav.html`, `foot.html` | Header and footer — shared by all four pages |
| `build/parts/home.html` etc. | One page's content |
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
| `styles.css` | All styling, shared by every page |
| `main.js` | Cart, toast, case tape, category filters, nav state |
| `Logo.png` | Brand mark — also the favicon |

Every page pulls in the same `styles.css` and `main.js`, so a change to either lands
everywhere at once. The header and footer markup is copied into each page; if you edit
one, edit all four.

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

- **Verify the Riftbound details.** It's the newest game on the site and the one I'm
  least certain about — check the set name/code (Origins / OGN), the six domain names,
  the product list, and the card-type terms on the Riftbound page before publishing.
- **Spelling:** the logo reads "COLLECTIBLES" but the repo is named `aacollectables`.
  The site currently uses the logo's spelling everywhere. Pick one.
- **Placeholder content:** every listing, price, stock count and calendar date on the
  homepage is made up. Card names and set codes are real; the numbers are not.
  Replace before the site goes public. The footer shows a visible note saying so —
  remove that note once real inventory is in.
- **Counter hours** in the footer (Tue–Fri 11:00–7:00, Sat 10:00–6:00) imply a walk-in
  shop. Take them off unless that's true — in-person selling is parked for now
  (`DECISIONS.md` 003).
