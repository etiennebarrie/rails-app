# Timeout while reloading

This repository shows an issue around connection handling.

If a connection is opened during the boot process, if a reloadable file is changed, the next request will try to acquire all the connections, but will fail.

There's a timeout on lock acquisition of twice the timeout for connection checkouts, which is 5 seconds by default, for a total of 10 seconds.

So if you start a server, touch a reloadable file, then make a request, it will take 10 seconds to get a response.

```console
bin/rails server &
touch app/models/application_record.rb
time curl -s http://localhost:3000 >dev/null
```
