import 'package:css_inline_dart/css_inline_dart.dart';
import 'package:test/test.dart';

void main() {
  test('inlineCss works correctly', () async {
    const html = '<html><head><style>h1 { color: red; }</style></head><body><h1>Hello</h1></body></html>';
    final result = await inlineCss(html: html);
    expect(result, contains('style="color: red;"'));
    expect(result, contains('Hello</h1>'));
  });

  test('inlineCssSync works correctly', () {
    const html = '<html><head><style>h1 { color: red; }</style></head><body><h1>Hello</h1></body></html>';
    final result = inlineCssSync(html: html);
    expect(result, contains('style="color: red;"'));
    expect(result, contains('Hello</h1>'));
  });

  test('inlineFragment works correctly', () async {
    const html = '<h1>Hello</h1>';
    const css = 'h1 { color: blue; }';
    final result = await inlineFragment(html: html, css: css);
    expect(result, contains('style="color: blue;"'));
    expect(result, contains('Hello</h1>'));
  });
}
