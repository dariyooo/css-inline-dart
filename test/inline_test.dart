// What each option changes about the output.
//
// One case per option, so a regression names the option that broke rather than
// just reporting that inlining differs.
import 'package:css_inline_dart/css_inline_dart.dart';
import 'package:test/test.dart';

import 'inline_test_cases.dart';

void main() {
  group('inlineDocument', () {
    for (final testCase in documentCases) {
      test(testCase.description, () {
        expect(
          inlineDocument(testCase.html, options: testCase.options),
          testCase.expected,
        );
      });
    }
  });

  group('inlineFragment', () {
    for (final testCase in fragmentCases) {
      test(testCase.description, () {
        expect(
          inlineFragment(testCase.html, testCase.css, options: testCase.options),
          testCase.expected,
        );
      });
    }
  });

  group('failures', () {
    test('a base url that does not parse is rejected', () {
      expect(
        () => inlineDocument(
          '<html><body><p>x</p></body></html>',
          options: const InlineOptions(baseUrl: 'not a url'),
        ),
        throwsA(isA<CssInlineException>()),
      );
    });

    // The HTTP stack is compiled in only when a consumer asks for it, so the
    // request has to fail loudly rather than quietly do nothing.
    test('asking for remote stylesheets without them is rejected', () {
      expect(
        () => inlineDocument(
          '<html><body><p>x</p></body></html>',
          options: const InlineOptions(loadRemoteStylesheets: true),
        ),
        supportsRemoteStylesheets
            ? returnsNormally
            : throwsA(isA<CssInlineException>()),
      );
    });
  });

  test('a build reports whether it can fetch stylesheets', () {
    expect(supportsRemoteStylesheets, isA<bool>());
  });
}
