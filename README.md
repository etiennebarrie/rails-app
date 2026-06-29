# Mime registry storage benchmark

This app benchmarks the first PR of the "make the Mime type registry
Ractor-shareable" series — **"Deprecate `Mime::SET` / `Mime::LOOKUP` /
`Mime::EXTENSION_LOOKUP`"** — to answer one question:

> Once the public mutable constants are gone, does it matter whether the
> internal registries live in **private constants** (read lexically, served
> from the iseq inline cache) or in **module instance variables behind
> accessors** (an extra method hop on every read)?

Hypothesis: Mime lookups are a tiny fraction of a request, so the storage
choice should be invisible end-to-end — even for an action that does the least
work possible and for content negotiation.

## Branches under test

Both are the same deprecation commit; they differ **only** in
`actionpack/lib/action_dispatch/http/mime_type.rb` (the registry storage). They
live on `github.com/etiennebarrie/rails`:

| Branch             | SHA                                        | Storage                              |
| ------------------ | ------------------------------------------ | ------------------------------------ |
| `bench-mime/const` | `8eb2c4ad305b1e61ad6eb0c84ae0d98b71e54cc5` | private constants, read lexically    |
| `bench-mime/ivar`  | `2dabeedf534c139c684b3552f17f3267de62df48` | module ivars + `attr_reader` (a hop) |

The diff between them:

```ruby
# bench-mime/const
REGISTRY            = Mimes.new
LOOKUP_BY_STRING    = {}
LOOKUP_BY_EXTENSION = {}
private_constant :REGISTRY, :LOOKUP_BY_STRING, :LOOKUP_BY_EXTENSION
# ... Type.lookup_by_extension reads LOOKUP_BY_EXTENSION[...] directly

# bench-mime/ivar
@registry = Mimes.new
@lookup_by_string = {}
@lookup_by_extension = {}
class << self
  attr_reader :registry, :lookup_by_string, :lookup_by_extension # :nodoc:
end
# ... Type.lookup_by_extension reads Mime.lookup_by_extension[...]  (method hop)
```

## How to run

The app points `rails` at a local checkout via
`bundle config local.rails <path>` (with `disable_local_branch_check` /
`disable_local_revision_check`), so switching the rails branch is picked up
live by the path gem — no re-bundle needed.

```bash
RAILS=~/src/github.com/rails/rails   # your rails checkout

git -C "$RAILS" switch bench-mime/const
RAILS_ENV=production bin/rails runner benchmarks/mime_storage.rb > out_const.txt

git -C "$RAILS" switch bench-mime/ivar
RAILS_ENV=production bin/rails runner benchmarks/mime_storage.rb > out_ivar.txt

diff out_const.txt out_ivar.txt
```

The script drives the real Rack stack of this app (routing → controller →
format negotiation → render) through an integration session, then runs a
same-process microbench of the Mime read APIs whose implementation differs
between the two branches. Endpoints live in `BenchController`:

- `bench#plain` — `render plain:` (floor: barely touches Mime)
- `bench#template` — renders a template + partial (format resolution reads Mime)
- `bench#negotiate` — `respond_to { format.html …; format.text … }`
- `bench#json_negotiate` — `respond_to { format.html …; format.json … }`

## Results

Ruby 4.0.5, Rails 8.2.0.alpha, best-of-5. Request iters = 10,000; micro iters =
1,000,000. **Both branches measured under the same (warm) machine conditions** —
measuring `const` cold first made it look ~5 µs/req faster, but that vanished
once both were warm (the `plain` baseline, which barely touches Mime, moved by
the same amount, confirming it was thermal/ordering noise, not Mime).

### YJIT on (production default)

| request cycle (µs/req) | const  | ivar   |
| ---------------------- | ------ | ------ |
| plain (baseline)       | 105.65 | 105.42 |
| template render        | 115.13 | 113.53 |
| respond_to html        | 109.48 | 109.03 |
| respond_to text        | 109.90 | 110.79 |
| respond_to accept      | 120.15 | 120.08 |
| respond_to json        | 104.04 | 104.15 |

| Mime API (ns/op)          | const   | ivar    |
| ------------------------- | ------- | ------- |
| `Mime[:html]`             | 82.94   | 85.20   |
| `Mime::Type.lookup(str)`  | 52.40   | 52.94   |
| `Mime::Type.parse(accept)`| 5657.67 | 5688.65 |
| `Mime.symbols`            | 39.00   | 37.28   |

Within noise everywhere. YJIT inlines the accessor hop, so constants and ivars
are performance-equivalent at both the request and micro level.

### YJIT off (worst case for the accessor hop)

| request cycle (µs/req) | const  | ivar   |
| ---------------------- | ------ | ------ |
| plain (baseline)       | 261.40 | 262.31 |
| template render        | 281.14 | 281.61 |
| respond_to html        | 269.34 | 270.17 |
| respond_to text        | 268.91 | 270.21 |
| respond_to accept      | 284.72 | 284.67 |
| respond_to json        | 253.34 | 252.59 |

| Mime API (ns/op)          | const   | ivar    | Δ        |
| ------------------------- | ------- | ------- | -------- |
| `Mime[:html]`             | 129.90  | 132.34  | +2.4 ns  |
| `Mime::Type.lookup(str)`  | 85.31   | 89.91   | +4.6 ns  |
| `Mime::Type.parse(accept)`| 7276.20 | 7330.56 | +0.7 %   |
| `Mime.symbols`            | 62.27   | 65.65   | +3.4 ns  |

Without YJIT the accessor hop costs a real but tiny **~2–5 ns/op** (the lexical
constant's inline cache is unbeatable in the interpreter). The request cycle is
still within ~1 µs (noise) between the two.

## Conclusion

Mime is a tiny slice of a request. The heaviest Mime op (`Mime[:html]`, ~83 ns
with YJIT / ~130 ns without) times the handful of lookups per request is well
under 1 % of a ~110 µs (YJIT) / ~270 µs (no-YJIT) request, and content
negotiation (`respond_to`, complex `Accept`) is not measurably impacted.

The constants-vs-ivars delta is **zero under YJIT** and a few ns/op without it —
never visible end-to-end. So the storage choice is a code-clarity decision, not
a performance one. Constants are equal-or-slightly-faster, so the PR's choice
carries no performance risk.
