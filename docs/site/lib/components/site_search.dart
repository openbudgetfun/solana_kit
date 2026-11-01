import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Header search control and modal for the static documentation site.
///
/// Styles live in `web/site.css`.
class SiteSearch extends StatelessComponent {
  /// Creates a docs search UI whose results are resolved relative to [basePath].
  const SiteSearch({required this.basePath, super.key});

  /// Base path where the documentation site is deployed.
  final String basePath;

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Component.element(
        tag: 'button',
        id: 'site-search-button',
        classes: 'site-search-button',
        attributes: {
          'type': 'button',
          'aria-label': 'Search documentation',
          'aria-keyshortcuts': 'Meta+K Control+K',
          'data-search-base-path': basePath,
        },
        children: const [
          span(classes: 'site-search-icon', [Component.text('⌕')]),
          span(classes: 'site-search-button-label', [Component.text('Search')]),
          Component.element(tag: 'kbd', children: [Component.text('⌘K')]),
        ],
      ),
      const div(
        id: 'site-search-dialog',
        classes: 'site-search-dialog',
        attributes: {
          'hidden': '',
          'role': 'dialog',
          'aria-modal': 'true',
          'aria-label': 'Search documentation',
        },
        [
          div(classes: 'site-search-backdrop', []),
          div(classes: 'site-search-panel', [
            div(classes: 'site-search-input-row', [
              span(classes: 'site-search-icon', [Component.text('⌕')]),
              Component.element(
                tag: 'input',
                id: 'site-search-input',
                classes: 'site-search-input',
                attributes: {
                  'type': 'search',
                  'placeholder': 'Search Solana Kit docs…',
                  'autocomplete': 'off',
                  'spellcheck': 'false',
                },
              ),
              Component.element(
                tag: 'button',
                id: 'site-search-close',
                classes: 'site-search-close',
                attributes: {'type': 'button', 'aria-label': 'Close search'},
                children: [Component.text('Esc')],
              ),
            ]),
            div(id: 'site-search-results', classes: 'site-search-results', []),
            div(id: 'site-search-empty', classes: 'site-search-empty', [
              Component.text(
                'Type to search pages, package names, guides, and APIs.',
              ),
            ]),
          ]),
        ],
      ),
      const script(content: _script),
    ]);
  }
}

const _script = r'''
(() => {
  if (window.__solanaKitDocsSearchInitialized) {
    return;
  }
  window.__solanaKitDocsSearchInitialized = true;

  const button = document.getElementById('site-search-button');
  const dialog = document.getElementById('site-search-dialog');
  const backdrop = dialog?.querySelector('.site-search-backdrop');
  const closeButton = document.getElementById('site-search-close');
  const input = document.getElementById('site-search-input');
  const results = document.getElementById('site-search-results');
  const empty = document.getElementById('site-search-empty');

  if (!button || !dialog || !input || !results || !empty) {
    return;
  }

  const basePath = button.dataset.searchBasePath || '/';
  const indexUrl = `${basePath}${basePath.endsWith('/') ? '' : '/'}search-index.json`;
  let indexPromise;
  let selectedIndex = -1;

  const normalize = (value) => value.toLowerCase().replace(/[^a-z0-9_\s/-]+/g, ' ').replace(/\s+/g, ' ').trim();
  const escapeHtml = (value) => value.replace(/[&<>"]/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[char]));
  const hrefForRoute = (route) => `${basePath}${basePath.endsWith('/') ? '' : '/'}${route.replace(/^\//, '')}`;

  const loadIndex = () => {
    indexPromise ??= fetch(indexUrl)
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Search index request failed: ${response.status}`);
        }
        return response.json();
      })
      .then((entries) => entries.map((entry) => ({
        ...entry,
        searchText: normalize([
          entry.title,
          entry.description,
          entry.route,
          ...(entry.headings || []),
          entry.content,
        ].filter(Boolean).join(' ')),
      })));

    return indexPromise;
  };

  const open = () => {
    dialog.hidden = false;
    document.documentElement.classList.add('site-search-open');
    loadIndex().then(() => render(input.value)).catch(() => {
      empty.textContent = 'Search is unavailable. The search index could not be loaded.';
    });
    requestAnimationFrame(() => input.focus());
  };

  const close = () => {
    dialog.hidden = true;
    document.documentElement.classList.remove('site-search-open');
    selectedIndex = -1;
    button.focus();
  };

  const score = (entry, terms, query) => {
    const title = normalize(entry.title || '');
    const route = normalize(entry.route || '');
    let value = 0;

    if (title === query) value += 120;
    if (title.includes(query)) value += 60;
    if (route.includes(query)) value += 35;

    for (const term of terms) {
      if (title.includes(term)) value += 30;
      if (route.includes(term)) value += 15;
      if (entry.searchText.includes(term)) value += 4;
    }

    return value;
  };

  const render = async (rawQuery) => {
    const query = normalize(rawQuery);
    selectedIndex = -1;
    results.innerHTML = '';

    if (!query) {
      empty.hidden = false;
      empty.textContent = 'Type to search pages, package names, guides, and APIs.';
      return;
    }

    const terms = query.split(' ').filter(Boolean);
    const entries = await loadIndex();
    const matches = entries
      .map((entry) => ({ entry, score: score(entry, terms, query) }))
      .filter((match) => match.score > 0 && terms.every((term) => match.entry.searchText.includes(term)))
      .sort((a, b) => b.score - a.score || a.entry.title.localeCompare(b.entry.title))
      .slice(0, 12);

    empty.hidden = matches.length !== 0;
    empty.textContent = matches.length === 0 ? 'No docs matched your search.' : '';

    results.innerHTML = matches.map(({ entry }, index) => `
      <a class="site-search-result" href="${escapeHtml(hrefForRoute(entry.route))}" data-search-result="${index}">
        <div class="site-search-result-title">${escapeHtml(entry.title || entry.route)}</div>
        <div class="site-search-result-route">${escapeHtml(entry.route)}</div>
        ${entry.description ? `<div class="site-search-result-description">${escapeHtml(entry.description)}</div>` : ''}
      </a>
    `).join('');
  };

  const selectResult = (delta) => {
    const links = [...results.querySelectorAll('[data-search-result]')];
    if (links.length === 0) {
      return;
    }

    selectedIndex = (selectedIndex + delta + links.length) % links.length;
    links.forEach((link, index) => link.setAttribute('aria-selected', index === selectedIndex ? 'true' : 'false'));
    links[selectedIndex].scrollIntoView({ block: 'nearest' });
  };

  button.addEventListener('click', open);
  closeButton?.addEventListener('click', close);
  backdrop?.addEventListener('click', close);
  input.addEventListener('input', () => render(input.value));
  results.addEventListener('click', () => {
    dialog.hidden = true;
    document.documentElement.classList.remove('site-search-open');
  });

  document.addEventListener('keydown', (event) => {
    const isSearchShortcut = event.key.toLowerCase() === 'k' && (event.metaKey || event.ctrlKey);
    if (isSearchShortcut) {
      event.preventDefault();
      dialog.hidden ? open() : close();
      return;
    }

    if (dialog.hidden) {
      return;
    }

    if (event.key === 'Escape') {
      event.preventDefault();
      close();
    } else if (event.key === 'ArrowDown') {
      event.preventDefault();
      selectResult(1);
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      selectResult(-1);
    } else if (event.key === 'Enter' && selectedIndex >= 0) {
      event.preventDefault();
      results.querySelectorAll('[data-search-result]')[selectedIndex]?.click();
    }
  });
})();
''';
