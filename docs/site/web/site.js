// Solana Kit docs: small progressive enhancements. The pages are complete
// without this script; it adds the theme toggle, copy buttons, example tabs,
// the mobile sidebar, table-of-contents tracking, and scroll reveals.
(() => {
  const root = document.documentElement;
  const themeKey = "solana-kit-docs:theme";

  // ---------- Theme ----------

  const currentTheme = () =>
    root.dataset.theme ||
    (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");

  for (const toggle of document.querySelectorAll("[data-theme-toggle]")) {
    const label = () =>
      toggle.setAttribute(
        "aria-label",
        currentTheme() === "dark" ? "Switch to light paper" : "Switch to dark paper",
      );
    label();
    toggle.addEventListener("click", () => {
      const next = currentTheme() === "dark" ? "light" : "dark";
      root.dataset.theme = next;
      try {
        localStorage.setItem(themeKey, next);
      } catch (error) {
        // Private browsing: the choice lasts for this page only.
      }
      label();
    });
  }

  // ---------- Copy buttons ----------

  const copy = async (button, text) => {
    try {
      await navigator.clipboard.writeText(text);
      button.dataset.copied = "";
      button.textContent = "Copied!";
    } catch (error) {
      button.textContent = "Press ⌘C";
    }
    setTimeout(() => {
      delete button.dataset.copied;
      button.textContent = "Copy";
    }, 1600);
  };

  document.addEventListener("click", (event) => {
    const button = event.target.closest("[data-copy-code], [data-copy-text]");
    if (!button) return;
    if (button.hasAttribute("data-copy-text")) {
      copy(button, button.dataset.copyText);
      return;
    }
    const code = button.closest(".code-frame")?.querySelector("pre code");
    if (code) copy(button, code.textContent);
  });

  // ---------- Example tabs ----------

  for (const switcher of document.querySelectorAll("[data-tabs]")) {
    const tabs = [...switcher.querySelectorAll('[role="tab"]')];
    const select = (tab, focus) => {
      for (const other of tabs) {
        const selected = other === tab;
        other.setAttribute("aria-selected", selected ? "true" : "false");
        other.tabIndex = selected ? 0 : -1;
        const panel = document.getElementById(other.getAttribute("aria-controls"));
        if (panel) panel.toggleAttribute("data-inactive", !selected);
      }
      if (focus) tab.focus();
    };
    switcher.addEventListener("click", (event) => {
      const tab = event.target.closest('[role="tab"]');
      if (tab) select(tab, false);
    });
    switcher.addEventListener("keydown", (event) => {
      const index = tabs.indexOf(document.activeElement);
      if (index === -1) return;
      const moves = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 };
      if (event.key in moves) {
        event.preventDefault();
        select(tabs[(index + moves[event.key] + tabs.length) % tabs.length], true);
      } else if (event.key === "Home" || event.key === "End") {
        event.preventDefault();
        select(tabs[event.key === "Home" ? 0 : tabs.length - 1], true);
      }
    });
  }

  // ---------- Mobile sidebar ----------

  const sidebarToggle = document.querySelector("[data-sidebar-toggle]");
  const scrim = document.querySelector("[data-sidebar-close]");
  const setSidebar = (open) => {
    root.classList.toggle("sidebar-open", open);
    sidebarToggle?.setAttribute("aria-expanded", open ? "true" : "false");
    sidebarToggle?.setAttribute("aria-label", open ? "Close the docs menu" : "Open the docs menu");
    if (scrim) scrim.hidden = !open;
  };
  sidebarToggle?.addEventListener("click", () =>
    setSidebar(!root.classList.contains("sidebar-open")),
  );
  scrim?.addEventListener("click", () => setSidebar(false));
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && root.classList.contains("sidebar-open")) {
      setSidebar(false);
      sidebarToggle?.focus();
    }
  });
  document
    .querySelector('.docs-sidebar [aria-current="page"]')
    ?.scrollIntoView({ block: "center" });

  // ---------- Table of contents tracking ----------

  const tocLinks = [...document.querySelectorAll(".docs-toc a[href*='#']")];
  if (tocLinks.length && "IntersectionObserver" in window) {
    const byId = new Map(
      tocLinks.map((link) => [decodeURIComponent(link.hash.slice(1)), link]),
    );
    const headings = [...byId.keys()]
      .map((id) => document.getElementById(id))
      .filter(Boolean);
    const visible = new Set();
    const mark = () => {
      const active =
        headings.find((heading) => visible.has(heading)) ??
        headings.filter((heading) => heading.getBoundingClientRect().top < 0).pop();
      for (const link of tocLinks) link.removeAttribute("aria-current");
      if (active) byId.get(active.id)?.setAttribute("aria-current", "true");
    };
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) visible.add(entry.target);
          else visible.delete(entry.target);
        }
        mark();
      },
      { rootMargin: "-80px 0px -60% 0px" },
    );
    for (const heading of headings) observer.observe(heading);
  }

  // ---------- Reveal on scroll ----------

  const reveals = document.querySelectorAll(".reveal");
  if (!("IntersectionObserver" in window)) {
    for (const element of reveals) element.classList.add("is-in");
  } else {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (!entry.isIntersecting) continue;
          entry.target.classList.add("is-in");
          observer.unobserve(entry.target);
        }
      },
      { rootMargin: "0px 0px -8% 0px" },
    );
    for (const element of reveals) observer.observe(element);
  }
})();
