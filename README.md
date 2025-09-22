# Performance improvement in JSON generation between Rails 8.0 and Rails 8.1

These branches define a benchmark for comparing JSON serialization between Rails 8.0 and Rails 8.1.

The benchmark doesn't use Active Record but simply serializes a large JSON document, taken from the ruby/json
benchmarks, which was originally an API response from Twitter. To run the benchmark, you'll need ruby/json checked out
or at least that file present.

The difference between Rails 8.0 and 8.1 is that JSON serialization no longer escapes some characters in the context of
rendering a JSON HTTP response.

* Rails 8.0, which escaped JSON: [json/8.0](https://github.com/etiennebarrie/rails-app/tree/json/8.0)
* Rails 8.1.0.beta1, which no longer escapes JSON: [json/8.1.0.beta1](https://github.com/etiennebarrie/rails-app/tree/json/8.1.0.beta1)
* Rails 8.1.0.beta1, restoring the escaping: [json/8.1.0.beta1-escape](https://github.com/etiennebarrie/rails-app/tree/json/8.1.0.beta1-escape)
* Rails main after [rails/rails#55726](https://github.com/rails/rails/pull/55726): [json/main](https://github.com/etiennebarrie/rails-app/tree/json/main)
