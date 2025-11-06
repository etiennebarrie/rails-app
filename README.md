# Mocha and Rails warning about missing assertions

```console
$ bin/rails test 2>&1 >/dev/null | sed s:$PWD/::
Test is missing assertions: `test_test_with_Mocha_assertion_not_incrementing_assertions_count` test/models/test_test.rb:9
```

The test is failing, but it does have an assertion provided by Mocha. Rails shouldn't show a warning here.
