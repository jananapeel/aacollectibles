/* AACollectibles — shared behaviour.
   Works as a plain multi-page site; the preview build adds a hash router on top. */
(function () {
  'use strict';

  /* ---- toast ---------------------------------------------------------- */
  var toast = document.getElementById('toast');
  var toastTimer;
  function say(msg) {
    if (!toast) return;
    toast.textContent = msg;
    toast.classList.add('on');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toast.classList.remove('on'); }, 2400);
  }

  /* ---- case tape: duplicate the run so the -50% loop never shows a gap -- */
  document.querySelectorAll('.tape-run').forEach(function (run) {
    run.innerHTML += run.innerHTML;
  });

  /* ---- cart ----------------------------------------------------------- */
  var count = 0;
  function paintCount() {
    document.querySelectorAll('.count').forEach(function (el) { el.textContent = count; });
  }
  document.addEventListener('click', function (e) {
    var add = e.target.closest('[data-add]');
    if (add) {
      count++;
      paintCount();
      say('Added to cart — ' + add.getAttribute('data-add'));
      return;
    }
    if (e.target.closest('#cartBtn')) {
      say(count ? count + ' item' + (count > 1 ? 's' : '') + ' in your cart.' : 'Your cart is empty.');
    }
    if (e.target.closest('#searchBtn')) {
      say('Search opens the full catalogue — 9,500 listings.');
    }
  });

  /* ---- newsletter ----------------------------------------------------- */
  var subForm = document.getElementById('subForm');
  if (subForm) {
    subForm.addEventListener('submit', function (e) {
      e.preventDefault();
      var input = document.getElementById('subEmail');
      say('You’re on the list. Drop alerts go to ' + input.value + '.');
      input.value = '';
    });
  }

  /* ---- category filters ------------------------------------------------ */
  /* Each .fchip carries data-facet + data-value; each .listing carries
     data-<facet> attributes. One active value per facet, "all" clears it. */
  document.querySelectorAll('[data-filters]').forEach(function (scope) {
    var chips = scope.querySelectorAll('.fchip');
    var grid = document.getElementById(scope.getAttribute('data-filters'));
    if (!grid) return;
    var items = Array.prototype.slice.call(grid.querySelectorAll('.listing'));
    var empty = grid.querySelector('.no-results');
    var countEl = scope.querySelector('.result-count');
    var state = {};

    function apply() {
      var shown = 0;
      items.forEach(function (item) {
        var ok = Object.keys(state).every(function (facet) {
          var want = state[facet];
          return want === 'all' || (item.dataset[facet] || '').split(' ').indexOf(want) > -1;
        });
        item.hidden = !ok;
        if (ok) shown++;
      });
      if (empty) empty.hidden = shown > 0;
      if (countEl) countEl.textContent = shown + (shown === 1 ? ' listing' : ' listings');
    }

    chips.forEach(function (chip) {
      chip.addEventListener('click', function () {
        var facet = chip.dataset.facet;
        state[facet] = chip.dataset.value;
        chips.forEach(function (other) {
          if (other.dataset.facet === facet) {
            other.setAttribute('aria-pressed', String(other === chip));
          }
        });
        apply();
      });
    });
    apply();
  });

  /* ---- theme toggle ---------------------------------------------------- */
  /* The inline bootstrap in <head> has already stamped data-theme, so there is
     no flash here; this only handles the switch and remembers the choice. */
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
  window.AAC = {
    markNav: function (key) {
      document.querySelectorAll('.nav a[data-page],.mobile-nav a[data-page]').forEach(function (a) {
        a.classList.toggle('is-active', a.dataset.page === key);
      });
    },
    say: say
  };

  var path = (location.pathname.split('/').pop() || 'index.html').replace('.html', '');
  window.AAC.markNav(path === '' ? 'index' : path);
})();

/* Shows: dim dates that have passed and label how far off the next one is.
   Driven off data-show-date so the static HTML never carries a stale
   "this weekend" that goes wrong the moment the page is a week old. */
(function () {
  'use strict';

  var today = new Date();
  today.setHours(0, 0, 0, 0);
  var DAY = 86400000;

  function parseDate(s) {
    var p = String(s).split('-');
    return new Date(+p[0], +p[1] - 1, +p[2]);
  }

  document.querySelectorAll('[data-show-date]').forEach(function (el) {
    if (parseDate(el.dataset.showDate) < today) el.classList.add('is-past');
  });

  document.querySelectorAll('[data-rel]').forEach(function (el) {
    var when = parseDate(el.getAttribute('data-rel'));
    var days = Math.round((when - today) / DAY);
    var weekday = when.toLocaleDateString(undefined, { weekday: 'long' });
    var label;

    if (days < 0) label = 'Last show';
    else if (days === 0) label = 'Today';
    else if (days === 1) label = 'Tomorrow';
    else if (days < 7) label = 'This ' + weekday;
    else if (days < 14) label = 'Next ' + weekday;
    else label = 'In ' + Math.round(days / 7) + ' weeks';

    el.textContent = label;
  });
})();
