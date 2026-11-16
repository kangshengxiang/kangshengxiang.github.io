require 'json'
require 'yaml'
require 'nokogiri'
require 'digest'
require 'uri'

root = File.expand_path('..', __dir__)
dest = File.expand_path(ARGV[0] || '_site', root)
abort "Build directory missing: #{dest}" unless File.directory?(dest)
paths = %w[index.html liver-cancer-research.html breast-cancer-research.html en/index.html en/liver-cancer-research.html en/breast-cancer-research.html]
errors = []
check = ->(condition, message) { errors << message unless condition }
config = YAML.safe_load(File.read(File.join(root, '_config.yml')))
origin = config['url'] + config.fetch('baseurl', '')
documents = {}
paths.each do |path|
  file = File.join(dest, path)
  check.call(File.file?(file), "Missing page #{path}")
  next unless File.file?(file)
  source = File.read(file)
  doc = Nokogiri::HTML(source)
  documents[path] = doc
  check.call(!source.match?(/\{\{|\{%/), "Unrendered Liquid in #{path}")
  check.call(doc.css('h1').length == 1, "Expected one h1 in #{path}")
  check.call(doc.at('html')['lang'] == (path.start_with?('en/') ? 'en' : 'zh-CN'), "Wrong language in #{path}")
  check.call(doc.css('link[rel=canonical]').length == 1, "Duplicate/missing canonical in #{path}")
  expected_url = origin + '/' + path.sub(/index\.html$/, '')
  check.call(doc.at('link[rel=canonical]')&.[]('href') == expected_url, "Wrong canonical in #{path}")
  %w[description keywords author robots twitter:card twitter:image].each do |meta|
    check.call(!doc.at("meta[name='#{meta}']")&.[]('content').to_s.empty?, "Missing #{meta} in #{path}")
  end
  check.call(doc.at("meta[name='robots']")['content'].start_with?('index,follow'), "Page is not indexable #{path}")
  %w[og:title og:description og:url og:image].each do |prop|
    check.call(!doc.at("meta[property='#{prop}']")&.[]('content').to_s.empty?, "Missing #{prop} in #{path}")
  end
  %w[zh-CN en x-default].each do |lang|
    check.call(doc.css("link[hreflang='#{lang}']").length == 1, "Missing/duplicate hreflang #{lang} in #{path}")
  end
  graphs = doc.css('script[type="application/ld+json"]').flat_map { |node| JSON.parse(node.text).fetch('@graph') }
  %w[Organization MedicalOrganization ResearchOrganization WebSite BreadcrumbList].each do |type|
    check.call(graphs.any? { |node| Array(node['@type']).include?(type) }, "Missing schema #{type} in #{path}")
  end
  faq = graphs.find { |node| node['@type'] == 'FAQPage' }
  if faq
    details = doc.css('details')
    check.call(details.length == faq['mainEntity'].length, "FAQ count differs #{path}")
    faq['mainEntity'].zip(details).each do |item, detail|
      next unless detail
      check.call(item['name'] == detail.at('summary').text.strip, "FAQ question mismatch #{path}")
      check.call(item['acceptedAnswer']['text'] == detail.at('p').text.strip, "FAQ answer mismatch #{path}")
    end
  end
  doc.css('a[href], img[src], script[src], link[href]').each do |node|
    link = node['href'] || node['src']
    next if link.start_with?('mailto:', 'tel:', 'data:', 'https://', 'http://')
    uri = URI.parse(link)
    candidate = uri.path.empty? ? file : (uri.path.start_with?('/') ? File.join(dest, uri.path) : File.expand_path(uri.path, File.dirname(file)))
    candidate = File.join(candidate, 'index.html') if File.directory?(candidate)
    check.call(File.file?(candidate), "Broken local link #{link} in #{path}")
    if uri.fragment && File.file?(candidate) && candidate.end_with?('.html')
      target_doc = Nokogiri::HTML(File.read(candidate))
      check.call(target_doc.at_css("[id='#{uri.fragment}']"), "Missing anchor #{link} in #{path}")
    end
  end
  doc.css('img').each do |img|
    check.call(img['alt'] && img['width'] && img['height'], "Missing image accessibility/dimensions #{path}")
  end
end
sitemap = Nokogiri::XML(File.read(File.join(dest, 'sitemap.xml'))) { |c| c.strict }
ns = {'s'=>'http://www.sitemaps.org/schemas/sitemap/0.9', 'x'=>'http://www.w3.org/1999/xhtml'}
check.call(sitemap.xpath('//s:url', ns).length == 6, 'Sitemap must list six pages')
sitemap.xpath('//s:url', ns).each do |entry|
  check.call(entry.xpath('x:link', ns).length == 3, 'Sitemap alternate languages missing')
end
check.call(File.read(File.join(dest, 'robots.txt')).include?(origin + '/sitemap.xml'), 'robots.txt sitemap URL differs')
check.call(File.read(File.join(dest, 'CNAME')).strip == 'kangshengxiang.com', 'Wrong custom domain')
expected_logo = '9c0b236e21393d36803e767059a90b84ed6777e3206154f49af905c8dcd087c2'
check.call(Digest::SHA256.file(File.join(dest, 'assets/logo-original.png')).hexdigest == expected_logo, 'Original logo bytes changed')
check.call(File.size(File.join(dest, 'assets/css/main.css')) > 10000, 'Minimal Mistakes Sass was not compiled')
check.call(!File.exist?(File.join(dest, 'Gemfile')), 'Development files leaked into site')
if errors.empty?
  puts "PASS: 6 pages; preserved URLs; canonical/hreflang; metadata; valid JSON-LD; visible FAQs; internal links/anchors; image dimensions; 6-entry XML sitemap; robots; CNAME; unchanged original logo; compiled Minimal Mistakes stylesheet."
else
  warn errors.join("\n")
  abort "FAIL: #{errors.length} checks"
end
