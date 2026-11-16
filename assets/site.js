const toggle = document.querySelector('.nav-toggle');
const menu = document.querySelector('.nav-links');

document.documentElement.classList.replace('no-js', 'js');
const currentPath = location.pathname.replace(/index\.html$/, '');
document.querySelectorAll('.nav-links a:not(.language-link)').forEach((link) => {
  const url = new URL(link.href);
  if (!url.hash && url.pathname.replace(/index\.html$/, '') === currentPath) {
    link.setAttribute('aria-current', 'page');
  }
});

if (toggle && menu) {
  toggle.addEventListener('click', () => {
    const open = toggle.getAttribute('aria-expanded') === 'true';
    toggle.setAttribute('aria-expanded', String(!open));
    menu.classList.toggle('open', !open);
  });

  menu.addEventListener('click', (event) => {
    if (event.target instanceof HTMLAnchorElement) {
      toggle.setAttribute('aria-expanded', 'false');
      menu.classList.remove('open');
    }
  });
}

document.querySelectorAll('[data-year]').forEach((node) => {
  node.textContent = String(new Date().getFullYear());
});
