# 北京康盛祥中医研究院 — Jekyll / Minimal Mistakes

This is the complete source for https://kangshengxiang.com. It uses Jekyll 3.10 and the official Minimal Mistakes 4.28.1 theme gem. The existing green, cream and gold Chinese design, original PNG logo, Chinese content and medical notices are preserved. The three English translations are retained as well. All six original addresses remain unchanged.

## Build and preview

Use Ruby 3.3 and Bundler 2.4.22 (or a compatible Bundler). Install a normal Ruby development environment; avoid modifying macOS system Ruby. Native gem dependencies may require compiler tools.

```sh
gem install bundler -v 2.4.22
bundle _2.4.22_ install
JEKYLL_ENV=production bundle exec jekyll build --trace
bundle exec ruby scripts/validate.rb
bundle exec jekyll doctor
bundle exec jekyll serve --host 127.0.0.1
```

Open http://127.0.0.1:4000. Generated HTML and compiled CSS are in `_site/`. Stop the preview with Ctrl+C. Restart Jekyll after changing `_config.yml`. `Gemfile.lock` pins the tested theme and dependency versions. The project was actually built and validated using Ruby 2.6.10 on the supplied host; Ruby 3.3 is configured for GitHub Actions. See `BUILD-REPORT.txt` for validation details and limits.

## Publish to GitHub Pages

1. Put the **contents** of this project folder at the repository root, including `.github/workflows/pages.yml`, `_config.yml`, `Gemfile`, `Gemfile.lock` and `CNAME`. Keep your repository history; review existing files before replacing them.
2. Use a `main` branch, or update the workflow's branch filter to your branch.
3. In repository Settings → Pages → Build and deployment, choose **GitHub Actions**. The included workflow installs Ruby 3.3, builds Jekyll, validates the generated pages and deploys `_site/`.
4. Keep the custom domain `kangshengxiang.com`; enable **Enforce HTTPS** once GitHub has provisioned its certificate. Keep the existing Cloudflare records pointing to GitHub Pages.
5. After deployment, confirm `/sitemap.xml` returns XML and submit it in your search-engine webmaster accounts.

Use the included Actions workflow, rather than the default branch-based GitHub Pages build: the official theme is installed as a pinned gem, and the workflow controls the dependency versions. No API keys are required. This delivery does not change the live website, DNS or repository.

## Structure and editing

- `index.html`, `liver-cancer-research.html`, `breast-cancer-research.html`: original Chinese page content with Jekyll front matter.
- `en/`: the three English pages.
- `_layouts/institute.html` → `_layouts/default.html`: a branded adaptation of the Minimal Mistakes document layout.
- `assets/css/main.scss`: imports the official theme skin and Sass, then resets theme defaults that would disturb the original design.
- `assets/css/institute.css`: the preserved original website stylesheet.
- `_includes/institute/`: reusable Chinese and English navigation/footer.
- `_includes/seo/`: per-page original SEO fields, canonical and reciprocal hreflang, Open Graph and Twitter metadata. These replace the theme's default SEO output to avoid duplicate canonicals and metadata.
- `_data/seo/`: original institution, website, breadcrumb, page and FAQ JSON-LD. FAQ text matches the visible page FAQs. DOI/ORCID placeholders remain explicit; no identifiers are invented.
- `assets/logo-original.png`: exact original image; SHA-256 checked by the validator.
- `sitemap.xml`, `robots.txt`, `llms.txt`, `site.webmanifest`, `CNAME`: crawling, AI-readable overview and domain configuration.
- `scripts/validate.rb`: validation of the actual generated website, used locally and in Actions.

The upstream theme's MIT notice is in `LICENSE-THEME.txt`. The site overrides the theme's shell, masthead, head, footer and scripts to preserve the institution's Chinese presentation; the theme's real Sass and copyright include remain in use. Blog search and analytics scripts are not loaded. Waline comments are loaded only on eligible pages after a real server URL is configured. The theme's dependencies may generate an empty `feed.xml`; the six-page bilingual sitemap is maintained explicitly and takes precedence over a generated sitemap.

Edit content inside each page's `<main>` element. Edit its `<title>` through the `title` front-matter field; adjust descriptions/keywords/social metadata in the matching SEO include. When changing a FAQ, update the matching JSON-LD under `_data/seo/` too and run the validator. Navigation language switches link to the equivalent topic, rather than always returning to a homepage.

The public site uses a root custom domain (`baseurl: ""`). Changing the domain requires updating `_config.yml`, `CNAME`, absolute URLs in `_data/seo/`, sitemap, robots and llms. The project is configured for `kangshengxiang.com`; subfolder hosting requires corresponding crawling and structured-data updates.

## SEO preserved

Unique titles/descriptions/keywords, author and publisher information, canonical URLs, bilingual reciprocal hreflang and x-default, Open Graph/Twitter Card, Organization/MedicalOrganization/ResearchOrganization/WebSite/BreadcrumbList JSON-LD, visible FAQ markup, citation fields, original logo dimensions/alt text, lazy loading below the fold and deferred JavaScript are retained. Schema describes the existing content and does not assert new credentials or publication identifiers. IndexNow remains an optional setup note; no indexing submission is performed by the build.

## References

- [Minimal Mistakes installation](https://mmistakes.github.io/minimal-mistakes/docs/installation/)
- [Minimal Mistakes configuration](https://mmistakes.github.io/minimal-mistakes/docs/configuration/)
- [Jekyll commands](https://jekyllrb.com/docs/usage/)

## Waline comments

### Server setup when not yet deployed

The website stays on GitHub Pages. Deploy only Waline's backend separately:

1. Open the [official quick start](https://waline.js.org/en/guide/get-started/) and use its Vercel deployment button. Create a separate project, for example `kangshengxiang-comments`.
2. In that Vercel project, open Storage, create/connect a Neon database, and open its SQL Editor.
3. Run the [official Waline PostgreSQL schema](https://github.com/walinejs/waline/blob/main/assets/waline.pgsql) once in the new database.
4. Redeploy the Vercel project after connecting storage. Copy the working deployment URL.
5. Visit that URL followed by `/ui/register`; the first registered account becomes administrator.
6. Paste the server URL into `waline.server_url` below, then push the Jekyll configuration to GitHub.

Optional: bind `comments.kangshengxiang.com` in Vercel. Add only the `comments` CNAME in Cloudflare using the exact target Vercel provides; leave the website's existing root and `www` records unchanged. Use DNS only during verification. Replace `waline.server_url` with the custom HTTPS address once it works.

Choose hosting/database plans appropriate for the institute. This package creates no paid resources. Once connected, test posting a comment and finding it in `/ui`.

The Waline 3.16.2 integration is in `_includes/waline.html` and `assets/waline.js`. It uses the site's green/cream palette and switches between Chinese and English. Comments are currently hidden on every page and disabled by default for future posts. There are currently no blog posts in this project.

GitHub Pages serves static files; Waline also requires a separate backend and database. Follow the official [Waline deployment guide](https://waline.js.org/en/guide/get-started/) to provision that service. No backend or account is created by this project. Set your real HTTPS server URL in `_config.yml`:

```yaml
waline:
  enabled: true
  server_url: "https://YOUR-ACTUAL-WALINE-SERVER"
  client_version: "3.16.2"
```

The delivered configuration now uses `https://waline-hazel-delta-73.vercel.app`. Comments render on eligible pages after publication. If you clear `server_url`, no comment section, CDN stylesheet, script or backend requests are rendered. Live comment submission has not been verified.

After setting the URL, rebuild/push the project. Register the first administrator at `<your-server-url>/ui/register` as described by Waline, then use `/ui` to manage comments. Confirm allowed website origins and moderation settings in your backend deployment. Never put database passwords, tokens or server secrets in Jekyll configuration; only the public server URL belongs here.

Use `comments: true` in page front matter to show comments or `comments: false` to hide them. New posts inherit `comments: false`. Each language/topic uses its own stable page URL as the comment thread key. An optional `comment_id: /my-stable-thread` lets you keep a thread if you later change a permalink, or share it across translations.

Waline's code is loaded as the section approaches the viewport. Image upload, GIF search and emoji downloads are disabled. A display name is required and email is optional. Visitors can use Waline's own authentication facilities when the backend supports them. Client-side settings do not replace backend moderation or access controls.

Validation commands:

```sh
JEKYLL_ENV=production bundle exec jekyll build
bundle exec ruby scripts/validate.rb
bundle exec ruby scripts/validate-waline.rb _site
```

The Waline validator automatically reads the configuration. Test submitting a comment and checking it in the Waline dashboard on your deployment.
