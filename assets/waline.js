// Loaded only for pages with comments and a configured Waline server.
const target = document.getElementById('waline');

async function mountComments() {
  if (!target) return;
  const { server, version, lang, path } = target.dataset;
  try {
    if (new URL(server).protocol !== 'https:') throw new Error('HTTPS required');
    if (!/^\d+\.\d+\.\d+$/.test(version)) throw new Error('Invalid version');
    const { init } = await import(`https://unpkg.com/@waline/client@${version}/dist/waline.js`);
    const status = target.querySelector('.waline-status');
    if (status) status.remove();
    init({
      el: target,
      serverURL: server,
      path,
      lang,
      meta: ['nick', 'mail', 'link'],
      requiredMeta: ['nick'],
      pageSize: 10,
      imageUploader: false,
      search: false,
      emoji: false,
    });
  } catch (error) {
    target.replaceChildren();
    const message = document.createElement('p');
    message.setAttribute('role', 'status');
    message.textContent = lang === 'en'
      ? 'Comments could not be loaded. Please try reloading the page later.'
      : '留言暂时无法加载，请稍后刷新页面重试。';
    target.append(message);
    console.warn('Waline could not be initialized.', error);
  }
}

if (target && 'IntersectionObserver' in window) {
  const observer = new IntersectionObserver((entries) => {
    if (entries.some((entry) => entry.isIntersecting)) {
      observer.disconnect();
      mountComments();
    }
  }, { rootMargin: '200px' });
  observer.observe(target);
} else {
  mountComments();
}
