# Generates the static prototype pages and the theme stylesheet.
#
#   pwsh build/build.ps1            regenerate the site
#   pwsh build/build.ps1 -Preview   also emit build/preview.html (single self-contained
#                                   file with the logo inlined and hash routing, for
#                                   sharing a preview without hosting anything)
#
# Sources of truth, all edited by hand:
#   styles.css                  the whole design system, shared with the theme
#   main.js                     prototype behaviour
#   build/parts/*.html          page fragments; nav.html and foot.html are shared
#   build/shopify-additions.css appended to make theme/assets/styles.css
#   build/build.ps1             this file — the product catalogue lives below
#
# Generated, do not hand-edit:
#   index.html pokemon.html one-piece.html riftbound.html
#   theme/assets/styles.css
#
# ASCII-only on purpose: Windows PowerShell 5.1 reads BOM-less scripts as ANSI, so
# non-ASCII literals here would mojibake. HTML entities instead. The parts/*.html
# files are read as UTF-8 and can contain anything.

[CmdletBinding()]
param([switch]$Preview)

$ErrorActionPreference = 'Stop'
$HERE = $PSScriptRoot
$ROOT = Split-Path $HERE -Parent
$U8   = [Text.UTF8Encoding]::new($false)

function RT($p) { [IO.File]::ReadAllText($p, $U8) }
function WT($p, $s) { [IO.File]::WriteAllText($p, $s, $U8) }

$POKE = 'Pok&#233;mon'
$DOT  = '&#183;'

# ---------------------------------------------------------------- catalogue
# Placeholder inventory for the prototype. Real stock lives in Shopify - see
# DECISIONS.md 005. Card names and set codes are real; every number is invented.
function L($face,$game,$rar,$cfName,$cfCode,$title,$setline,$condCls,$condTxt,$price,$stock,$attrs) {
  [pscustomobject]@{
    face=$face; game=$game; rar=$rar; cfName=$cfName; cfCode=$cfCode; title=$title
    setline=$setline; condCls=$condCls; condTxt=$condTxt; price=$price; stock=$stock; attrs=$attrs
  }
}

$catalogue = @{
  'home' = @(
    (L 'cf-night' $POKE 'SIR' 'Umbreon VMAX' '215/203' 'Umbreon VMAX &#8212; Alt Art' "Evolving Skies $DOT 215/203 $DOT EN" 'c-gem' 'PSA 10 GEM MINT' '$1,480' '1 in stock' @{}),
    (L 'cf-ember' $POKE 'SIR' 'Charizard ex' '199/165' 'Charizard ex &#8212; Special Illustration' "Scarlet &amp; Violet 151 $DOT 199/165 $DOT EN" 'c-gem' 'PSA 9 MINT' '$412' '2 in stock' @{}),
    (L 'cf-crim' 'One Piece' 'MANGA' 'Shanks' 'OP09-093' 'Shanks &#8212; Manga Rare' "OP-09 Emperors in the New World $DOT EN" 'c-gem' 'BGS 9.5' '$740' '1 in stock' @{}),
    (L 'cf-deep' 'One Piece' "L $DOT ALT" 'Monkey.D.Luffy' 'OP01-003' 'Monkey.D.Luffy &#8212; Leader Parallel' "OP-01 Romance Dawn $DOT OP01-003 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$96' '3 in stock' @{}),
    (L 'cf-crim' 'Riftbound' 'SIG' 'Jinx' 'OGN-142' 'Jinx &#8212; Signature' "Origins $DOT OGN-142 $DOT EN" 'c-gem' 'PSA 10 GEM MINT' '$188' '1 in stock' @{}),
    (L 'cf-steel' 'Riftbound' 'SEALED' 'Proving Grounds' 'STARTER' 'Riftbound Proving Grounds' "Two-player starter $DOT EN $DOT Factory sealed" 'c-seal' 'SEALED' '$42' '12 in stock' @{})
  )

  'pokemon' = @(
    (L 'cf-night' $POKE 'SIR' 'Umbreon VMAX' '215/203' 'Umbreon VMAX &#8212; Alt Art' "Evolving Skies $DOT 215/203 $DOT EN" 'c-gem' 'PSA 10 GEM MINT' '$1,480' '1 in stock' @{era='swsh';type='graded'}),
    (L 'cf-ember' $POKE 'SIR' 'Charizard ex' '199/165' 'Charizard ex &#8212; Special Illustration' "Scarlet &amp; Violet 151 $DOT 199/165 $DOT EN" 'c-gem' 'PSA 9 MINT' '$412' '2 in stock' @{era='sv';type='graded'}),
    (L 'cf-rune' $POKE 'SIR' 'Sylveon ex' '170/131' 'Sylveon ex &#8212; Special Illustration' "Prismatic Evolutions $DOT 170/131 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$86' '4 in stock' @{era='sv';type='raw'}),
    (L 'cf-sun' $POKE 'SIR' 'Pikachu ex' '238/191' 'Pikachu ex &#8212; Special Illustration' "Surging Sparks $DOT 238/191 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$124' '2 in stock' @{era='sv';type='raw'}),
    (L 'cf-ember' $POKE 'HOLO' 'Charizard' '4/102' 'Charizard &#8212; Base Set Holo' "Base Set $DOT 4/102 $DOT Unlimited" 'c-gem' 'PSA 7 NEAR MINT' '$1,150' '1 in stock' @{era='wotc';type='graded'}),
    (L 'cf-sun' $POKE 'SHINY' 'Shining Charizard' '107/105' 'Shining Charizard' "Neo Destiny $DOT 107/105 $DOT EN" 'c-nm' 'RAW / LIGHT PLAY' '$640' '1 in stock' @{era='wotc';type='raw'}),
    (L 'cf-ember' $POKE 'SHINY' 'Charizard GX' 'SV49/SV94' 'Charizard GX &#8212; Shiny Vault' "Hidden Fates $DOT SV49/SV94 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$78' '3 in stock' @{era='sm';type='raw'}),
    (L 'cf-steel' $POKE 'SEALED' 'Elite Trainer Box' 'SV 8.5' 'Prismatic Evolutions ETB' "Scarlet &amp; Violet 8.5 $DOT EN $DOT Factory sealed" 'c-seal' 'SEALED / LIMIT 2' '$89' '24 in stock' @{era='sv';type='sealed'}),
    (L 'cf-steel' $POKE 'SEALED' 'Booster Bundle' 'SV 3.5' '151 Booster Bundle' "Scarlet &amp; Violet 151 $DOT JP print $DOT Sealed" 'c-seal' 'SEALED' '$56' '9 in stock' @{era='sv';type='sealed'})
  )

  'one-piece' = @(
    (L 'cf-crim' 'One Piece' 'MANGA' 'Shanks' 'OP09-093' 'Shanks &#8212; Manga Rare' "OP-09 Emperors in the New World $DOT EN" 'c-gem' 'BGS 9.5' '$740' '1 in stock' @{arc='late';type='graded'}),
    (L 'cf-deep' 'One Piece' 'LEADER' 'Monkey.D.Luffy' 'OP01-003' 'Monkey.D.Luffy &#8212; Leader Parallel' "OP-01 Romance Dawn $DOT OP01-003 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$96' '3 in stock' @{arc='early';type='raw'}),
    (L 'cf-jade' 'One Piece' 'SEC' 'Boa Hancock' 'OP01-078' 'Boa Hancock &#8212; Alternate Art' "OP-01 Romance Dawn $DOT OP01-078 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$128' '4 in stock' @{arc='early';type='raw'}),
    (L 'cf-ember' 'One Piece' 'SR' 'Portgas.D.Ace' 'OP02-013' 'Portgas.D.Ace &#8212; Alternate Art' "OP-02 Paramount War $DOT OP02-013 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$112' '2 in stock' @{arc='early';type='raw'}),
    (L 'cf-volt' 'One Piece' 'LEADER' 'Trafalgar Law' 'OP05-041' 'Trafalgar Law &#8212; Leader' "OP-05 Awakening of the New Era $DOT EN" 'c-gem' 'PSA 10 GEM MINT' '$310' '1 in stock' @{arc='mid';type='graded'}),
    (L 'cf-rune' 'One Piece' 'SEC' 'Kaido' 'OP06-035' 'Kaido &#8212; Alternate Art' "OP-06 Wings of the Captain $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$154' '2 in stock' @{arc='mid';type='raw'}),
    (L 'cf-sun' 'One Piece' 'MANGA' 'Yamato' 'OP10-118' 'Yamato &#8212; Manga Rare' "OP-10 Royal Blood $DOT OP10-118 $DOT EN" 'c-nm' 'RAW / NEAR MINT' '$268' '1 in stock' @{arc='late';type='raw'}),
    (L 'cf-steel' 'One Piece' 'SEALED' 'Starter Deck' 'ST-21' 'ST-21 Starter Deck &#8212; Gear 5' "Starter deck $DOT EN $DOT Factory sealed" 'c-seal' 'SEALED' '$28' '16 in stock' @{arc='starter';type='sealed'}),
    (L 'cf-steel' 'One Piece' 'SEALED' 'Booster Box' 'OP-12' 'OP-12 Booster Box' "Legacy of the Master $DOT EN $DOT 24 packs" 'c-seal' 'SEALED / LIMIT 1' '$118' '6 in stock' @{arc='late';type='sealed'})
  )

  'riftbound' = @(
    (L 'cf-crim' 'Riftbound' 'SIG' 'Jinx' 'OGN-142' 'Jinx &#8212; Signature' "Origins $DOT OGN-142 $DOT Chaos" 'c-gem' 'PSA 10 GEM MINT' '$188' '1 in stock' @{domain='chaos';type='graded'}),
    (L 'cf-ember' 'Riftbound' 'LEGEND' 'Yasuo' 'OGN-018' 'Yasuo &#8212; Legend' "Origins $DOT OGN-018 $DOT Fury" 'c-nm' 'RAW / NEAR MINT' '$54' '3 in stock' @{domain='fury';type='raw'}),
    (L 'cf-sun' 'Riftbound' 'EPIC' 'Lux' 'OGN-076' 'Lux &#8212; Showcase Alt Art' "Origins $DOT OGN-076 $DOT Order" 'c-nm' 'RAW / NEAR MINT' '$72' '2 in stock' @{domain='order';type='raw'}),
    (L 'cf-rune' 'Riftbound' 'LEGEND' 'Viktor' 'OGN-101' 'Viktor &#8212; Legend' "Origins $DOT OGN-101 $DOT Mind" 'c-nm' 'RAW / NEAR MINT' '$46' '5 in stock' @{domain='mind';type='raw'}),
    (L 'cf-jade' 'Riftbound' 'EPIC' 'Volibear' 'OGN-055' 'Volibear &#8212; Champion Unit' "Origins $DOT OGN-055 $DOT Body" 'c-nm' 'RAW / NEAR MINT' '$31' '6 in stock' @{domain='body';type='raw'}),
    (L 'cf-volt' 'Riftbound' 'SIG' 'Ahri' 'OGN-129' 'Ahri &#8212; Signature' "Origins $DOT OGN-129 $DOT Calm" 'c-gem' 'BGS 9.5' '$142' '1 in stock' @{domain='calm';type='graded'}),
    (L 'cf-volt' 'Riftbound' 'FIELD' 'Howling Abyss' 'OGN-B04' 'Howling Abyss &#8212; Battlefield' "Origins $DOT OGN-B04 $DOT Calm" 'c-nm' 'RAW / NEAR MINT' '$24' '8 in stock' @{domain='calm';type='raw'}),
    (L 'cf-steel' 'Riftbound' 'SEALED' 'Proving Grounds' 'STARTER' 'Proving Grounds Two-Player Starter' "Riftbound $DOT EN $DOT Factory sealed" 'c-seal' 'SEALED' '$42' '12 in stock' @{type='sealed'}),
    (L 'cf-steel' 'Riftbound' 'SEALED' 'Booster Box' 'OGN' 'Origins Booster Box' "Origins $DOT EN $DOT 24 packs" 'c-seal' 'SEALED / LIMIT 1' '$128' '4 in stock' @{type='sealed'})
  )
}

# ---------------------------------------------------------------- emit cards
function Render-Listings($items) {
  $sb = New-Object Text.StringBuilder
  foreach ($i in $items) {
    $data = ''
    foreach ($k in ($i.attrs.Keys | Sort-Object)) { $data += " data-$k=""$($i.attrs[$k])""" }
    $addName = ($i.title -replace '&#8212;', '-') -replace '&amp;', 'and'
    [void]$sb.Append(@"
      <article class="listing"$data>
        <div class="cardface $($i.face)">
          <div class="orb"></div><div class="ring"></div>
          <div class="cf-top"><span class="cf-game">$($i.game)</span><span class="cf-rar">$($i.rar)</span></div>
          <div class="cf-bot"><b>$($i.cfName)</b><span>$($i.cfCode)</span></div>
          <div class="sheen"></div>
        </div>
        <div class="listing-meta">
          <h3>$($i.title)</h3>
          <p class="set">$($i.setline)</p>
          <span class="cond $($i.condCls)">$($i.condTxt)</span>
          <div class="buy">
            <div><span class="price">$($i.price)</span><span class="stock">$($i.stock)</span></div>
            <button class="add" type="button" data-add="$addName">Add</button>
          </div>
        </div>
      </article>

"@)
  }
  $sb.ToString()
}

# ---------------------------------------------------------------- assemble
$nav  = RT "$HERE\parts\nav.html"
$foot = RT "$HERE\parts\foot.html"
$css  = RT "$ROOT\styles.css"
$js   = RT "$ROOT\main.js"

$pages = @(
  @{ key='index';     part='home.html';      title='AACollectibles'; desc='AACollectibles - Pokemon, One Piece and Riftbound trading cards. Singles, graded slabs and sealed product, hand-graded and shipped same day.' },
  @{ key='pokemon';   part='pokemon.html';   title='Pokemon TCG - AACollectibles'; desc='Pokemon TCG singles, graded slabs and sealed product. Base Set through Scarlet and Violet, English and Japanese print.' },
  @{ key='one-piece'; part='one-piece.html'; title='One Piece Card Game - AACollectibles'; desc='One Piece Card Game singles from OP-01 onward. Leaders, alt arts, manga rares and sealed boxes.' },
  @{ key='riftbound'; part='riftbound.html'; title='Riftbound - AACollectibles'; desc='Riftbound, the League of Legends TCG. Origins singles, Legends, Battlefields and starter product.' },
  @{ key='shows'; part='shows.html'; title='Shows - AACollectibles'; desc='Card shows AACollectibles tables at most weekends. Dates, times, venues and table numbers.' }
)

$bodies = @{}
foreach ($p in $pages) {
  $html = RT "$HERE\parts\$($p.part)"
  foreach ($key in $catalogue.Keys) {
    $token = "<!--LISTINGS:$key-->"
    if ($html.Contains($token)) { $html = $html.Replace($token, (Render-Listings $catalogue[$key])) }
  }
  $bodies[$p.key] = $html
}

# ---- 1. the static pages --------------------------------------------------
foreach ($p in $pages) {
  $head = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$($p.title)</title>
<meta name="description" content="$($p.desc)">
<link rel="icon" href="Logo.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Archivo+Black&family=Archivo:wght\@400;500;600;700&family=DM+Mono:wght\@400;500&display=swap">
<link rel="stylesheet" href="styles.css">
<script>/* stamp the saved theme before first paint so there is no flash */
(function(){try{var t=localStorage.getItem('aac-theme');if(t)document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>
</head>
<body>
"@
  $head = $head.Replace('\@', '@')
  $doc = $head + $nav.Replace('__LOGO__','Logo.png') + "`n<main>`n" + $bodies[$p.key].Replace('__LOGO__','Logo.png') + "`n</main>`n" +
         $foot.Replace('__LOGO__','Logo.png') + "`n<script src=""main.js""></script>`n</body>`n</html>`n"
  $name = if ($p.key -eq 'index') { 'index.html' } else { "$($p.key).html" }
  WT "$ROOT\$name" $doc
  "  $name"
}

# ---- 2. the theme stylesheet ----------------------------------------------
# Keeps theme/assets/styles.css byte-identical to the root file up to the
# SHOPIFY THEME ADDITIONS banner, so the two copies cannot drift.
$add = RT "$HERE\shopify-additions.css"
WT "$ROOT\theme\assets\styles.css" ($css + $add)
"  theme/assets/styles.css"

# ---- 3. optional single-file preview --------------------------------------
if ($Preview) {
  $logo = 'data:image/png;base64,' + [Convert]::ToBase64String([IO.File]::ReadAllBytes("$ROOT\Logo.png"))

  function ToHashLinks($s) {
    $s = $s.Replace('href="index.html#sell"',    'href="#index~sell"')
    $s = $s.Replace('href="index.html#grading"', 'href="#index~grading"')
    $s = $s.Replace('href="index.html"',         'href="#index"')
    $s = $s.Replace('href="pokemon.html"',       'href="#pokemon"')
    $s = $s.Replace('href="one-piece.html"',     'href="#one-piece"')
    $s = $s.Replace('href="riftbound.html"',     'href="#riftbound"')
    $s = $s.Replace('href="shows.html"',         'href="#shows"')
    $s
  }

  $routes = ''
  foreach ($p in $pages) {
    $hidden = if ($p.key -eq 'index') { '' } else { ' hidden' }
    $routes += "<div class=""route"" data-route=""$($p.key)""$hidden>`n" + (ToHashLinks $bodies[$p.key]) + "`n</div>`n"
  }

  $router = @'

/* preview-only: hash router so the four pages work inside one file */
(function () {
  var routes = {};
  document.querySelectorAll('[data-route]').forEach(function (r) { routes[r.dataset.route] = r; });
  var current = null;

  function show() {
    var raw = decodeURIComponent(location.hash.replace(/^#/, ''));
    var parts = raw.split('~');
    var key = parts[0] || 'index';
    if (!routes[key]) {
      if (current) return;        // an in-page anchor: let the browser handle it
      key = 'index';
    }
    if (current !== key) {
      Object.keys(routes).forEach(function (k) { routes[k].hidden = (k !== key); });
      current = key;
      if (window.AAC) window.AAC.markNav(key);
    }
    var anchor = parts[1] && document.getElementById(parts[1]);
    if (anchor) { anchor.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
    else { window.scrollTo(0, 0); }
  }

  window.addEventListener('hashchange', show);
  show();
})();
'@

  $previewDoc = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>AACollectibles</title>
<script>(function(){try{var t=localStorage.getItem('aac-theme');if(t)document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Archivo+Black&family=Archivo:wght\@400;500;600;700&family=DM+Mono:wght\@400;500&display=swap">
<style>
$css
.route[hidden]{display:none}
</style>
</head>
<body>
$((ToHashLinks $nav).Replace('__LOGO__', $logo))
<main>
$($routes.Replace('__LOGO__', $logo))
</main>
$((ToHashLinks $foot).Replace('__LOGO__', $logo))
<script>
$js
$router
</script>
</body>
</html>
"@
  $previewDoc = $previewDoc.Replace('\@', '@')
  WT "$HERE\preview.html" $previewDoc
  "  build/preview.html"
}

"done."
