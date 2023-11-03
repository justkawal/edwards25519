dart pub global run coverage:test_with_coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html