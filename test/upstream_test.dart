// The upstream `css-inline` test suite, run against the Dart binding.
//
// The cases are generated from the Rust tests — see
// tool/generate_upstream_tests.dart. A failure here means the binding and the
// crate disagree, so fix the binding rather than the expectation.
import 'package:css_inline_dart/css_inline_dart.dart';
import 'package:test/test.dart';

import 'upstream_test_cases.dart';

void main() {
  group('upstream inlineDocument', () {
    for (final testCase in upstreamDocumentCases) {
      test(testCase.description, () {
        expect(
          inlineDocument(testCase.html, options: testCase.options),
          testCase.expected,
        );
      });
    }
  });

  group('upstream inlineFragment', () {
    for (final testCase in upstreamFragmentCases) {
      test(testCase.description, () {
        expect(
          inlineFragment(
            testCase.html,
            testCase.css,
            options: testCase.options,
          ),
          testCase.expected,
        );
      });
    }
  });
}
