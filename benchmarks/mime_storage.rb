# A/B benchmark for the "Deprecate Mime::SET / Mime::LOOKUP / Mime::EXTENSION_LOOKUP"
# PR: does storing the Mime registries as module instance variables (read through
# accessors) cost anything versus private constants (read lexically)?
#
# The two checkouts differ only in
# actionpack/lib/action_dispatch/http/mime_type.rb:
#   constants: REGISTRY / LOOKUP_BY_STRING / LOOKUP_BY_EXTENSION
#              (lexical reads, served from the iseq inline cache)
#   ivars:     @registry / @lookup_by_string / @lookup_by_extension + attr_reader
#              (an extra method hop on every read)
#
# Branches under test (github.com/etiennebarrie/rails):
#   bench-mime/const  8eb2c4ad305b1e61ad6eb0c84ae0d98b71e54cc5   (private constants)
#   bench-mime/ivar   2dabeedf534c139c684b3552f17f3267de62df48   (module ivars + accessors)
#
# Run against each checkout and diff the output. The app points rails at a local
# checkout via `bundle config local.rails <path>`, so just switch the branch
# there in between:
#
#   git -C <rails> switch bench-mime/const
#   RAILS_ENV=production bin/rails runner benchmarks/mime_storage.rb
#   git -C <rails> switch bench-mime/ivar
#   RAILS_ENV=production bin/rails runner benchmarks/mime_storage.rb
#
# YJIT (on by default in production via load_defaults) is reported in the header.

require "action_dispatch/testing/integration"

ITERS = (ARGV[0] || 10_000).to_i
MICRO = (ARGV[1] || 1_000_000).to_i

BRANCH = begin
  root = Gem.loaded_specs["rails"]&.full_gem_path
  root ? Dir.chdir(root) { `git rev-parse --abbrev-ref HEAD`.strip } : "?"
end

Rails.logger.level = Logger::FATAL
ActiveSupport::LogSubscriber.logger = nil if ActiveSupport::LogSubscriber.respond_to?(:logger=)

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 " \
     "(KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
ACCEPT_COMPLEX = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"

session = ActionDispatch::Integration::Session.new(Rails.application)

SCENARIOS = {
  "plain (baseline)"  => ["/bench/plain",     "text/html"],
  "template render"   => ["/bench/template",  "text/html"],
  "respond_to html"   => ["/bench/negotiate", "text/html"],
  "respond_to text"   => ["/bench/negotiate", "text/plain"],
  "respond_to accept" => ["/bench/negotiate", ACCEPT_COMPLEX],
  "respond_to json"   => ["/bench/json",      "application/json"],
}

def hit(session, path, accept)
  session.get(path, headers: { "HTTP_ACCEPT" => accept, "HTTP_USER_AGENT" => UA })
end

# Verify each scenario is 200 and warm routing/compilation.
SCENARIOS.each do |name, (path, accept)|
  hit(session, path, accept)
  st = session.response.status
  abort "#{name}: status #{st}\n#{session.response.body[0, 300]}" unless st == 200
end
2_000.times { SCENARIOS.each_value { |path, accept| hit(session, path, accept) } }

def timeit(iters)
  GC.start
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  iters.times { yield }
  Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
end

yjit = (defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?) ? "on" : "off"
puts "=== rails #{Rails::VERSION::STRING}  branch=#{BRANCH}  ruby #{RUBY_VERSION} yjit=#{yjit} ==="

puts "REQUEST CYCLE  (iters=#{ITERS}, best of 5)"
SCENARIOS.each do |name, (path, accept)|
  best = Array.new(5) { timeit(ITERS) { hit(session, path, accept) } }.min
  puts "  %-20s %8.2f us/req  %9.0f req/s" % [name, best / ITERS * 1e6, ITERS / best]
end

# The raw Mime read APIs whose implementation differs between the two branches.
OPS = {
  "Mime[:html]"              => -> { Mime[:html] },
  "Mime::Type.lookup(str)"   => -> { Mime::Type.lookup("text/html") },
  "Mime::Type.parse(accept)" => -> { Mime::Type.parse(ACCEPT_COMPLEX) },
  "Mime.symbols"             => -> { Mime.symbols },
}
puts "MIME API MICROBENCH  (iters=#{MICRO}, best of 5)"
OPS.each do |name, blk|
  best = Array.new(5) { timeit(MICRO) { blk.call } }.min
  puts "  %-26s %7.2f ns/op  %12.0f ops/s" % [name, best / MICRO * 1e9, MICRO / best]
end
