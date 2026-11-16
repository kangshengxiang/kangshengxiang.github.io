require 'nokogiri'
require 'uri'
require 'yaml'

root = File.expand_path('..', __dir__)
destination = File.expand_path(ARGV[0] || '_site', root)
config = YAML.safe_load(File.read(File.join(root, '_config.yml')))
waline = config.fetch('waline', {})
enabled = if ARGV[1]
  ARGV[1] == 'on'
else
  waline['enabled'] && !waline.fetch('server_url', '').strip.empty?
end
pages = %w[index.html en/index.html liver-cancer-research.html breast-cancer-research.html en/liver-cancer-research.html en/breast-cancer-research.html]
active_count = 0
pages.each do |path|
  doc = Nokogiri::HTML(File.read(File.join(destination, path)))
  source = File.read(File.join(root, path))
  front_matter = YAML.safe_load(source.split(/^---\s*$\n?/)[1]) || {}
  default_comments = config.fetch('defaults', []).select { |entry| entry.fetch('scope', {}) == {'path' => ''} }.last
  comments = front_matter.fetch('comments', default_comments&.fetch('values', {})&.fetch('comments', false))
  expected = enabled && comments == true
  active_count += 1 if expected
  sections = doc.css('#waline')
  scripts = doc.css('script[src]').select { |node| node['src'].end_with?('/assets/waline.js') }
  css = doc.css('link[rel=stylesheet]').select { |node| node['href'].include?('@waline/client@') }
  abort "Wrong comment section count in #{path}" unless sections.length == (expected ? 1 : 0)
  abort "Wrong script count in #{path}" unless scripts.length == (expected ? 1 : 0)
  abort "Wrong CSS count in #{path}" unless css.length == (expected ? 1 : 0)
  next unless expected
  node = sections.first
  abort "Server must be HTTPS in #{path}" unless URI.parse(node['data-server']).scheme == 'https'
  abort "Wrong comment language in #{path}" unless node['data-lang'] == (path.start_with?('en/') ? 'en' : 'zh-CN')
  abort "Wrong thread key in #{path}" unless node['data-path'] == '/' + path
end
puts "PASS: Waline rendered on #{active_count} pages; widget, CSS and script omitted on #{pages.length - active_count} pages, matching configuration."
