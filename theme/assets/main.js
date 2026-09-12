/* AACollectibles — Shopify theme behaviour.
   Differs from the static prototype in one important way: the cart is real.
   Adds go through Shopify's AJAX Cart API, and the header count is read back
   from the server rather than being a number we keep in a variable. */
(function () {
  'use strict';

  /* ---- toast ----------------------------------------------------------- */
  var toast = document.getElementById('toast');
  var toastTimer;
  function say(msg) {
    if (!toast) return;
    toast.textContent = msg;
    toast.classList.add('on');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toast.classList.remove('on'); }, 2400);
  }

  /* ---- counter strip: duplicate so the -50% loop never shows a gap ------ */
  document.querySelectorAll('.tape-run').forEach(function (run) {
    run.innerHTML += run.innerHTML;
  });

  /* ---- cart ------------------------------------------------------------ */
  function paintCount(n) {
    document.querySelectorAll('[data-cart-count]').forEach(function (el) {
      el.textContent = n;
    });
  }

  function refreshCount() {
    return fetch(window.Shopify.routes.root + 'cart.js', { headers: { Accept: 'application/json' } })
      .then(function (r) { return r.json(); })
      .then(function (cart) { paintCount(cart.item_count); return cart; });
  }

  /* Intercept any add-to-cart form. Selected by action rather than by a data
     attribute so it works with Shopify's {% form 'product' %} output too.
     Without JS the form still posts normally and lands on /cart — no dead end. */
  document.addEventListener('submit', function (e) {
    var form = e.target;
    if (!form.action || form.action.indexOf('/cart/add') === -1) return;

    e.preventDefault();
    var btn = form.querySelector('[type="submit"]');
    var title = (btn && btn.dataset.title) || 'Item';
    if (btn) { btn.disabled = true; }

    fetch(form.action + '.js', {
      method: 'POST',
      body: new FormData(form),
      headers: { Accept: 'application/json' }
    })
      .then(function (r) { return r.json().then(function (body) { return { ok: r.ok, body: body }; }); })
      .then(function (res) {
        if (!res.ok) {
          say(res.body.description || 'That one is already spoken for.');
          return;
        }
        say('Added to cart — ' + title);
        return refreshCount();
      })
      .catch(function () {
        say('Could not reach the cart. Check your connection and try again.');
      })
      .then(function () {
        if (btn) { btn.disabled = false; }
      });
  });

  /* ---- product: option chips drive the real variant -------------------- */
  var variantSelect = document.querySelector('[data-variant-select]');
  if (variantSelect) {
    var form = variantSelect.closest('form');
    form.addEventListener('change', function (e) {
      if (!e.target.matches('input[type="radio"][name^="option-"]')) return;

      var picked = Array.prototype.map.call(
        form.querySelectorAll('input[type="radio"][name^="option-"]:checked'),
        function (r) { return r.value; }
      ).join(' / ');

      var match = Array.prototype.find.call(variantSelect.options, function (o) {
        return o.dataset.title === picked;
      });
      if (!match) return;

      variantSelect.value = match.value;

      var priceEl = document.querySelector('.pdp-price');
      if (priceEl && match.dataset.price) { priceEl.textContent = match.dataset.price; }

      var addBtn = form.querySelector('.pdp-add');
      if (addBtn) {
        var sold = match.disabled;
        addBtn.disabled = sold;
        addBtn.textContent = sold ? 'Sold' : 'Add to cart';
      }
    });
  }

  /* ---- theme toggle ---------------------------------------------------- */
  var root = document.documentElement;
  var THEME_KEY = 'aac-theme';
  var themeBtn = document.getElementById('themeBtn');

  function activeTheme() {
    return root.getAttribute('data-theme') ||
      (window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
  }
  function labelTheme() {
    if (!themeBtn) return;
    var next = activeTheme() === 'dark' ? 'light' : 'dark';
    themeBtn.setAttribute('aria-label', 'Switch to ' + next + ' theme');
    themeBtn.setAttribute('title', 'Switch to ' + next + ' theme');
  }
  if (themeBtn) {
    labelTheme();
    themeBtn.addEventListener('click', function () {
      var next = activeTheme() === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem(THEME_KEY, next); } catch (e) { /* private mode */ }
      labelTheme();
      say(next === 'light' ? 'Light theme on.' : 'Dark theme on.');
    });
  }

  /* ---- mobile drawer --------------------------------------------------- */
  var menuBtn = document.getElementById('menuBtn');
  var mobileNav = document.getElementById('mobileNav');
  if (menuBtn && mobileNav) {
    var setMenu = function (open) {
      mobileNav.hidden = !open;
      menuBtn.setAttribute('aria-expanded', String(open));
      menuBtn.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    };
    menuBtn.addEventListener('click', function () { setMenu(mobileNav.hidden); });
    mobileNav.addEventListener('click', function (e) {
      if (e.target.closest('a')) setMenu(false);
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && !mobileNav.hidden) { setMenu(false); menuBtn.focus(); }
    });
    window.addEventListener('resize', function () {
      if (window.innerWidth > 1000 && !mobileNav.hidden) setMenu(false);
    });
  }

  /* ---- nav active state ------------------------------------------------ */
  var here = window.location.pathname;
  document.querySelectorAll('.nav a[href],.mobile-nav a[href]').forEach(function (a) {
    var href = a.getAttribute('href');
    if (href && href !== '/' && here.indexOf(href) === 0) a.classList.add('is-active');
  });
})();
