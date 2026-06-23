import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Header search control and modal for the static documentation site.
class SiteSearch extends StatelessComponent {
  /// Creates a docs search UI whose results are resolved relative to [basePath].
  const SiteSearch({required this.basePath, super.key});

  /// Base path where the documentation site is deployed.
  final String basePath;

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const Document.head(
        children: [
          Component.element(tag: 'style', children: [Component.text(_styles)]),
        ],
      ),
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

const _styles = '''
.site-search-button {
  align-items: center;
  background: color-mix(in srgb, var(--background), var(--text) 4%);
  border: 1px solid color-mix(in srgb, var(--text), transparent 86%);
  border-radius: 0.65rem;
  color: color-mix(in srgb, var(--text), transparent 18%);
  cursor: pointer;
  display: inline-flex;
  font: inherit;
  gap: 0.65rem;
  height: 2.25rem;
  padding: 0 0.45rem 0 0.8rem;
}

.site-search-button:hover,
.site-search-button:focus-visible {
  background: color-mix(in srgb, var(--primary), transparent 90%);
  border-color: color-mix(in srgb, var(--primary), transparent 55%);
  color: var(--text);
  outline: none;
}

.site-search-button kbd {
  background: color-mix(in srgb, var(--text), transparent 92%);
  border: 1px solid color-mix(in srgb, var(--text), transparent 84%);
  border-radius: 0.45rem;
  color: color-mix(in srgb, var(--text), transparent 24%);
  font-size: 0.72rem;
  line-height: 1;
  padding: 0.28rem 0.38rem;
}

.site-search-dialog[hidden] {
  display: none;
}

.site-search-dialog {
  inset: 0;
  position: fixed;
  z-index: 1000;
}

.site-search-backdrop {
  background: color-mix(in srgb, #020617, transparent 35%);
  inset: 0;
  position: absolute;
}

.site-search-panel {
  background: var(--background);
  border: 1px solid color-mix(in srgb, var(--text), transparent 86%);
  border-radius: 1rem;
  box-shadow: 0 1.5rem 4rem color-mix(in srgb, #020617, transparent 55%);
  left: 50%;
  max-height: min(42rem, calc(100vh - 2rem));
  max-width: min(44rem, calc(100vw - 1.5rem));
  overflow: hidden;
  position: absolute;
  top: 6rem;
  transform: translateX(-50%);
  width: 100%;
}

.site-search-input-row {
  align-items: center;
  border-bottom: 1px solid color-mix(in srgb, var(--text), transparent 90%);
  display: flex;
  gap: 0.75rem;
  padding: 0.85rem 1rem;
}

.site-search-icon {
  color: color-mix(in srgb, var(--text), transparent 48%);
  font-size: 1.35rem;
}

.site-search-input {
  background: transparent;
  border: 0;
  color: var(--text);
  flex: 1;
  font: inherit;
  font-size: 1rem;
  outline: none;
}

.site-search-close {
  background: color-mix(in srgb, var(--text), transparent 94%);
  border: 1px solid color-mix(in srgb, var(--text), transparent 86%);
  border-radius: 0.5rem;
  color: color-mix(in srgb, var(--text), transparent 28%);
  cursor: pointer;
  font-size: 0.75rem;
  padding: 0.3rem 0.5rem;
}

.site-search-results {
  display: flex;
  flex-direction: column;
  max-height: min(32rem, calc(100vh - 10rem));
  overflow-y: auto;
  padding: 0.45rem;
}

.site-search-result {
  border-radius: 0.75rem;
  color: inherit;
  display: block;
  padding: 0.75rem 0.85rem;
  text-decoration: none;
}

.site-search-result:hover,
.site-search-result:focus-visible,
.site-search-result[aria-selected="true"] {
  background: color-mix(in srgb, var(--primary), transparent 90%);
  outline: none;
}

.site-search-result-title {
  color: var(--text);
  font-weight: 650;
}

.site-search-result-route {
  color: color-mix(in srgb, var(--primary), var(--text) 20%);
  font-size: 0.8rem;
  margin-top: 0.15rem;
}

.site-search-result-description {
  color: color-mix(in srgb, var(--text), transparent 30%);
  font-size: 0.9rem;
  line-height: 1.45;
  margin-top: 0.35rem;
}

.site-search-empty {
  color: color-mix(in srgb, var(--text), transparent 38%);
  font-size: 0.92rem;
  padding: 1.25rem;
  text-align: center;
}

@media (max-width: 640px) {
  .site-search-button-label {
    display: none;
  }

  .site-search-panel {
    top: 4.75rem;
  }
}
''';

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
