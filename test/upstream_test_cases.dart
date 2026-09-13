// GENERATED FILE — DO NOT EDIT.
//
// Produced by tool/generate_upstream_tests.dart from the
// css-inline Rust test suite at revision d60b8a3:
// css-inline/tests/test_inlining.rs, test_selectors.rs.
//
// Regenerate after bumping the crate:
//   dart run tool/generate_upstream_tests.dart
//
// 105 cases from 98 upstream test functions.
//
// Not ported (30 test functions):
//   test_inlining.rs::ignore_inlining_attribute_style — asserts a predicate rather than an expected document
//   test_inlining.rs::ignore_inlining_attribute_link — asserts a predicate rather than an expected document
//   test_inlining.rs::simple_merge — asserts a predicate rather than an expected document
//   test_inlining.rs::invalid_rule — parameterised by #[test_case], asserts on error strings
//   test_inlining.rs::remote_file_stylesheet — needs the file feature and an on-disk stylesheet
//   test_inlining.rs::missing_stylesheet — needs the file feature and an on-disk stylesheet
//   test_inlining.rs::remote_file_stylesheet_disable — needs the file feature and an on-disk stylesheet
//   test_inlining.rs::remote_network_stylesheet — needs the http feature and a local server
//   test_inlining.rs::remote_network_stylesheet_invalid_url — asserts on an error string, which the binding rewords
//   test_inlining.rs::remote_network_stylesheet_same_scheme — needs the http feature and a local server
//   test_inlining.rs::remote_network_relative_stylesheet — needs the http feature and a local server
//   test_inlining.rs::file_scheme — needs the file feature and an on-disk stylesheet
//   test_inlining.rs::customize_inliner — no recognised assertion shape
//   test_inlining.rs::use_builder — no recognised assertion shape
//   test_inlining.rs::inline_to — writes into a Rust sink, which the binding does not expose
//   test_inlining.rs::keep_link_tags — needs the http feature and a local server
//   test_inlining.rs::test_cache — gated behind a cargo feature this build does not enable
//   test_inlining.rs::test_disable_cache — gated behind a cargo feature this build does not enable
//   test_inlining.rs::test_resolver_without_implementation — asserts on an error string, which the binding rewords
//   test_inlining.rs::inline_fragment_to — writes into a Rust sink, which the binding does not expose
//   test_inlining.rs::indexed_id_selector_large_document — performance test over a generated document
//   test_inlining.rs::indexed_class_selector_large_document — performance test over a generated document
//   test_inlining.rs::indexed_tag_selector_large_document — performance test over a generated document
//   test_inlining.rs::indexed_descendant_selector_large_document — performance test over a generated document
//   test_inlining.rs::indexed_child_selector_large_document — performance test over a generated document
//   test_inlining.rs::indexed_multiple_selectors_fallback_large_document — performance test over a generated document
//   test_inlining.rs::indexed_multiple_elements_same_class_large_document — performance test over a generated document
//   test_inlining.rs::indexed_pseudo_class_selector_large_document — performance test over a generated document
//   test_inlining.rs::indexed_compound_tag_class_large_document — performance test over a generated document
//   test_inlining.rs::remove_inlined_selectors_only_at_rules — asserts a predicate rather than an expected document
//
// Upstream is MIT licensed — see LICENSE-THIRD-PARTY.
import 'package:css_inline_dart/css_inline_dart.dart';

import 'inline_test_cases.dart';

/// Documents upstream inlines, and what it expects back.
const upstreamDocumentCases = <DocumentCase>[
  DocumentCase(
    description: 'no_existing_style',
    html: '<html><head><style>h1, h2 { color:red; }\nstrong { text-decoration:none }\np { font-size:2px }\np.footer { font-size: 1px}</style></head><body><h1>Big Text</h1>\n<p><strong>Yes!</strong></p>\n<p class="footer">Foot notes</p></body></html>',
    expected: '<html><head></head><body><h1 style="color: red;">Big Text</h1>\n<p style="font-size: 2px;"><strong style="text-decoration: none;">Yes!</strong></p>\n<p class="footer" style="font-size: 1px;">Foot notes</p></body></html>',
  ),
  DocumentCase(
    description: 'ignore_inlining_attribute_tag',
    html: '<html><head><style>h1 { color:blue; }</style></head><body><h1 data-css-inline="ignore">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 data-css-inline="ignore">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'keep_attribute_style',
    html: '\n<html>\n<head>\n<style data-css-inline="keep">\nh1 { color: blue; }\n</style>\n</head>\n<body>\n<h1>Big Text</h1>\n</body>\n</html>',
    expected: '<html><head>\n<style data-css-inline="keep">\nh1 { color: blue; }\n</style>\n</head>\n<body>\n<h1 style="color: blue;">Big Text</h1>\n\n</body></html>',
  ),
  DocumentCase(
    description: 'specificity_same_selector',
    html: '<html><head><style>\n.test-class {\n    padding-top: 15px;\n    padding: 10px;\n    padding-left: 12px;\n}</style></head><body><a class="test-class">Test</a></body></html>',
    expected: '<html><head></head><body><a class="test-class" style="padding-top: 15px;padding: 10px;padding-left: 12px;">Test</a></body></html>',
  ),
  DocumentCase(
    description: 'specificity_different_selectors',
    html: '<html><head><style>\n.test { padding-left: 16px; }\nh1 { padding: 0; }</style></head><body><h1 class="test"></h1></body></html>',
    expected: '<html><head></head><body><h1 class="test" style="padding: 0;padding-left: 16px;"></h1></body></html>',
  ),
  DocumentCase(
    description: 'specificity_different_selectors_existing_style',
    html: '<html><head><style>\n.test { padding-left: 16px; }\nh1 { padding: 0; }</style></head><body><h1 class="test" style="color: blue;"></h1></body></html>',
    expected: '<html><head></head><body><h1 class="test" style="padding: 0;padding-left: 16px;color: blue"></h1></body></html>',
  ),
  DocumentCase(
    description: 'specificity_merge_with_existing_style',
    html: '<html><head><style>.test { padding: 0; }</style></head><body><h1 class="test" style="padding-left: 16px"></h1></body></html>',
    expected: '<html><head></head><body><h1 class="test" style="padding: 0;padding-left: 16px"></h1></body></html>',
  ),
  DocumentCase(
    description: 'overlap_styles',
    html: '<html><head><style>\n.test-class {\n    color: #ffffff;\n}\na {\n    color: #17bebb;\n}</style></head><body><a class="test-class" href="https://example.com">Test</a></body></html>',
    expected: '<html><head></head><body><a class="test-class" href="https://example.com" style="color: #ffffff;">Test</a></body></html>',
  ),
  DocumentCase(
    description: 'overloaded_styles',
    html: '<html><head><style>h1 { color: red; } #test { color: blue; }</style></head><body><h1 id="test">Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 id="test" style="color: blue;">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'important',
    html: '<html><head><style>h1 { color: blue !important; }</style></head><body><h1 style="color: red;">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'important_with_space_at_the_end',
    html: '<html><head><style>h1 { color: blue !important  ; }</style></head><body><h1 style="color: red;">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'important_no_rule_exists',
    html: '<html><head><style>h1 { color: blue !important; }</style></head><body><h1 style="margin:0">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue;margin: 0">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'important_multiple_rules #1',
    html: '<html><head><style>.blue { color: blue !important; } .reset { color: unset }</style></head><body><h1 class="blue reset">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 class="blue reset" style="color: blue !important;">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'important_multiple_rules #2',
    html: '<html><head><style>.reset { color: unset } .blue { color: blue !important; }</style></head><body><h1 class="blue reset">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 class="blue reset" style="color: blue !important;">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'important_more_specific',
    html: '<html><head><style>h1 { color: unset !important } #title { color: blue !important; }</style></head><body><h1 id="title">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 id="title" style="color: blue !important;">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'important_inline_wins_over_stylesheet_important',
    html: '<html><head><style>h1 { color: blue !important; }</style></head><body><h1 style="color: red !important;">Big Text</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: red !important">Big Text</h1></body></html>',
  ),
  DocumentCase(
    description: 'font_family_quoted',
    html: '<html><head><style>h1 { font-family: "Open Sans", sans-serif; }</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="font-family: \'Open Sans\', sans-serif;">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'font_family_quoted_with_existing_inline_style',
    html: '<html><head><style>h1 { font-family: "Open Sans", sans-serif; }</style></head><body><h1 style="whitespace: nowrap">Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="font-family: \'Open Sans\', sans-serif;whitespace: nowrap">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'font_family_quoted_with_inline_style_override',
    html: '<html><head><style>h1 { font-family: "Open Sans", sans-serif !important; }</style></head><body><h1 style="font-family: Helvetica; whitespace: nowrap">Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="font-family: \'Open Sans\', sans-serif;whitespace: nowrap">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'other_property_quoted',
    html: '<html><head><style>h1 { --bs-font-sant-serif: system-ui,-applie-system,"helvetica neue"; }</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="--bs-font-sant-serif: system-ui,-applie-system,\'helvetica neue\';">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'href_attribute_unchanged',
    html: '<html>\n<head>\n    <style>h1 { color:blue; }</style>\n</head>\n<body>\n    <h1>Big Text</h1>\n    <a href="https://example.org/test?a=b&c=d">Link</a>\n</body>\n</html>',
    expected: '<html><head>\n    \n</head>\n<body>\n    <h1 style="color: blue;">Big Text</h1>\n    <a href="https://example.org/test?a=b&amp;c=d">Link</a>\n\n</body></html>',
  ),
  DocumentCase(
    description: 'complex_child_selector',
    html: '<html>\n   <head>\n      <style>.parent {\n         overflow: hidden;\n         box-shadow: 0 4px 10px 0px rgba(0, 0, 0, 0.1);\n         }\n         .parent > table > tbody > tr > td,\n         .parent > table > tbody > tr > td > div {\n         border-radius: 3px;\n         }\n      </style>\n   </head>\n   <body>\n      <div class="parent">\n         <table>\n            <tbody>\n               <tr>\n                  <td>\n                     <div>\n                        Test\n                     </div>\n                  </td>\n               </tr>\n            </tbody>\n         </table>\n      </div></body></html>',
    expected: '<html><head>\n      \n   </head>\n   <body>\n      <div class="parent" style="overflow: hidden;box-shadow: 0 4px 10px 0px rgba(0, 0, 0, 0.1);">\n         <table>\n            <tbody>\n               <tr>\n                  <td style="border-radius: 3px;">\n                     <div style="border-radius: 3px;">\n                        Test\n                     </div>\n                  </td>\n               </tr>\n            </tbody>\n         </table>\n      </div></body></html>',
  ),
  DocumentCase(
    description: 'existing_styles',
    html: '<html><head><style>h1 { color: red; }</style></head><body><h1 style="color: blue">Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'existing_styles_multiple_tags',
    html: '<html><head><style>h1 { color: red; }</style></head><body><h1 style="color: blue">Hello world!</h1><h1 style="color: blue">Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue">Hello world!</h1><h1 style="color: blue">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'existing_styles_with_merge',
    html: '<html><head><style>h1 { color: red; font-size:14px; }</style></head><body><h1 style="color: blue">Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="font-size: 14px;color: blue">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'existing_styles_with_merge_multiple_tags',
    html: '<html><head><style>h1 { color: red; font-size:14px; }</style></head><body><h1 style="color: blue">Hello world!</h1><h1 style="color: blue">Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="font-size: 14px;color: blue">Hello world!</h1><h1 style="font-size: 14px;color: blue">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'remove_multiple_style_tags_without_inlining',
    html: '\n<html>\n<head>\n<style>\nh1 {\n    text-decoration: none;\n}\n</style>\n<style>\n.test-class {\n        color: #ffffff;\n}\na {\n        color: #17bebb;\n}\n</style>\n</head>\n<body>\n<a class="test-class" href="https://example.com">Test</a>\n<h1>Test</h1>\n</body>\n</html>\n    ',
    expected: '<html><head>\n\n\n</head>\n<body>\n<a class="test-class" href="https://example.com">Test</a>\n<h1>Test</h1>\n\n\n    </body></html>',
    options: InlineOptions(keepStyleTags: false, inlineStyleTags: false),
  ),
  DocumentCase(
    description: 'do_not_process_style_tag',
    html: '<html><head><style>@media (max-width: 767px) { padding: 0;} h1 {background-color: blue;}</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head><style>@media (max-width: 767px) { padding: 0;} h1 {background-color: blue;}</style></head><body><h1>Hello world!</h1></body></html>',
    options: InlineOptions(inlineStyleTags: false, keepStyleTags: true),
  ),
  DocumentCase(
    description: 'do_not_process_and_remove_style_tag',
    html: '<html><head><style>@media (max-width: 767px) { padding: 0;} h1 {background-color: blue;}</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1>Hello world!</h1></body></html>',
    options: InlineOptions(keepStyleTags: false, inlineStyleTags: false),
  ),
  DocumentCase(
    description: 'do_not_process_and_remove_style_tag_but_keep_at_rules',
    html: '<html><head><style>@media (max-width: 767px) { padding: 0;} h1 {background-color: blue;}</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head><style>@media (max-width: 767px) { padding: 0;} </style></head><body><h1>Hello world!</h1></body></html>',
    options: InlineOptions(keepStyleTags: false, inlineStyleTags: false, keepAtRules: true),
  ),
  DocumentCase(
    description: 'empty_style',
    html: '<html><head><style></style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1>Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'media_query_ignore',
    html: '<html><head><style>@media screen and (max-width: 992px) {\n  body {\n    background-color: blue;\n  }\n}</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1>Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'remove_style_tag',
    html: '<html><head><style>@media (max-width: 600px) { h1 { font-size: 18px; } }\nh1 {background-color: blue;}</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="background-color: blue;">Hello world!</h1></body></html>',
  ),
  DocumentCase(
    description: 'remove_multiple_style_tags',
    html: '\n<html>\n<head>\n<style>\nh1 {\n    text-decoration: none;\n}\n@media (max-width: 600px) { h1 { font-size: 18px; } }\n</style>\n<style>\n.test-class {\n        color: #ffffff;\n}\na {\n        color: #17bebb;\n}\n</style>\n</head>\n<body>\n<a class="test-class" href="https://example.com">Test</a>\n<h1>Test</h1>\n</body>\n</html>\n    ',
    expected: '<html><head>\n\n\n</head>\n<body>\n<a class="test-class" href="https://example.com" style="color: #ffffff;">Test</a>\n<h1 style="text-decoration: none;">Test</h1>\n\n\n    </body></html>',
  ),
  DocumentCase(
    description: 'keep_multiple_at_rules',
    html: '\n<html>\n<head>\n<style>\n@media (max-width: 600px) { h1 { font-size: 18px; } }\n@media (max-width: 400px) { h1 { font-size: 12px; } }\n</style>\n<style>\n@media (max-width: 200px) { h1 { font-size: 8px; } }\n</style>\n</head>\n<body>\n<h1>Test</h1>\n</body>\n</html>\n    ',
    expected: '<html><head><style>@media (max-width: 600px) { h1 { font-size: 18px; } } @media (max-width: 400px) { h1 { font-size: 12px; } } @media (max-width: 200px) { h1 { font-size: 8px; } } </style>\n\n\n</head>\n<body>\n<h1>Test</h1>\n\n\n    </body></html>',
    options: InlineOptions(keepAtRules: true),
  ),
  DocumentCase(
    description: 'extra_css',
    html: '<html><head><style>h1 {background-color: blue;}</style></head><body><h1>Hello world!</h1></body></html>',
    expected: '<html><head></head><body><h1 style="background-color: green;">Hello world!</h1></body></html>',
    options: InlineOptions(inlineStyleTags: false, extraCss: 'h1 {background-color: green;}'),
  ),
  DocumentCase(
    description: 'keep_style_tags',
    html: '\n<html>\n<head>\n<style>\n@media (max-width: 600px) { h1 { font-size: 18px; } }\nh2 { color: red; }\n</style>\n</head>\n<body>\n<h2></h2>\n</body>\n</html>',
    expected: '<html><head>\n<style>\n@media (max-width: 600px) { h1 { font-size: 18px; } }\nh2 { color: red; }\n</style>\n</head>\n<body>\n<h2 style="color: red;"></h2>\n\n</body></html>',
    options: InlineOptions(keepStyleTags: true),
  ),
  DocumentCase(
    description: 'keep_at_rules',
    html: '\n<html>\n<head>\n<style>\nh1 { color: blue; }\n@media (max-width: 600px) { h1 { font-size: 18px; } }\np { margin: 10px; }\n</style>\n</head>\n<body>\n<h1>Hello</h1><p>World</p>\n</body>\n</html>',
    expected: '<html><head><style>@media (max-width: 600px) { h1 { font-size: 18px; } } </style>\n\n</head>\n<body>\n<h1 style="color: blue;">Hello</h1><p style="margin: 10px;">World</p>\n\n</body></html>',
    options: InlineOptions(keepAtRules: true),
  ),
  DocumentCase(
    description: 'minify_css',
    html: '\n<html>\n<head>\n<style>\nh1 {\n  color: blue;\n  font-weight: bold;\n}\n</style>\n</head>\n<body>\n<h1>Hello</h1>\n</body>\n</html>',
    expected: '<html><head>\n\n</head>\n<body>\n<h1 style="color:blue;font-weight:bold">Hello</h1>\n\n</body></html>',
    options: InlineOptions(minifyCss: true),
  ),
  DocumentCase(
    description: 'nth_child_selector',
    html: '\n<html>\n<head>\n<style>tbody tr:nth-child(odd) td {background-color:grey;}</style>\n</head>\n<body>\n<table>\n   <tbody>\n      <tr>\n         <td>Test</td>\n         <td>Test</td>\n      </tr>\n      <tr>\n         <td>Test</td>\n         <td>Test</td>\n      </tr>\n      <tr>\n         <td>Test</td>\n         <td>Test</td>\n      </tr>\n      <tr>\n         <td>Test</td>\n         <td>Test</td>\n      </tr>\n   </tbody>\n</table>\n</body>\n</html>',
    expected: '<html><head>\n\n</head>\n<body>\n<table>\n   <tbody>\n      <tr>\n         <td style="background-color: grey;">Test</td>\n         <td style="background-color: grey;">Test</td>\n      </tr>\n      <tr>\n         <td>Test</td>\n         <td>Test</td>\n      </tr>\n      <tr>\n         <td style="background-color: grey;">Test</td>\n         <td style="background-color: grey;">Test</td>\n      </tr>\n      <tr>\n         <td>Test</td>\n         <td>Test</td>\n      </tr>\n   </tbody>\n</table>\n\n</body></html>',
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_basic',
    html: '<html><head><style>h1 { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_partial',
    html: '<html><head><style>\nh1 { color: blue; }\nh2 { color: red; }\n</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style>h2 { color: red; }</style></head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_multiple_blocks',
    html: '<html><head>\n<style>h1 { color: blue; }</style>\n<style>h2 { color: red; }</style>\n</head><body><h1>Test</h1></body></html>',
    expected: '<html><head>\n\n<style>h2 { color: red; }</style>\n</head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_comma_separated',
    html: '<html><head><style>.a, .b { color: blue; }</style></head><body><div class="a">Test</div></body></html>',
    expected: '<html><head><style>.b { color: blue; }</style></head><body><div class="a" style="color: blue;">Test</div></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_with_at_rules',
    html: '<html><head><style>\nh1 { color: blue; }\n@media (max-width: 600px) { h1 { font-size: 18px; } }\n</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style>@media (max-width: 600px) { h1 { font-size: 18px; } } </style></head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true, keepAtRules: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_with_keep_style_tags',
    html: '<html><head><style>h1 { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style></style></head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true, keepStyleTags: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_empty_result',
    html: '<html><head><style>h1 { color: blue; } p { color: red; }</style></head><body><h1>Test</h1><p>Para</p></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue;">Test</h1><p style="color: red;">Para</p></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_no_match',
    html: '<html><head><style>.nonexistent { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style>.nonexistent { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_disabled',
    html: '<html><head><style>h1 { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: false),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_multiple_unmatched_after_removal',
    html: '<html><head><style>h1, .a, .b { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style>.a, .b { color: blue; }</style></head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_empty_selector_in_list',
    html: '<html><head><style>.a, , .b { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style>.a, .b { color: blue; }</style></head><body><h1>Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_no_style_tags',
    html: '<html><head></head><body><h1>Test</h1></body></html>',
    expected: '<html><head></head><body><h1>Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_all_matched_removes_style',
    html: '<html><head><style>h1, p { color: blue; }</style></head><body><h1>Title</h1><p>Text</p></body></html>',
    expected: '<html><head></head><body><h1 style="color: blue;">Title</h1><p style="color: blue;">Text</p></body></html>',
    options: InlineOptions(removeInlinedSelectors: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_keep_style_tags_partial',
    html: '<html><head><style>h1 { color: blue; } .unmatched { color: red; }</style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style>.unmatched { color: red; }</style></head><body><h1 style="color: blue;">Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true, keepStyleTags: true),
  ),
  DocumentCase(
    description: 'remove_inlined_selectors_empty_style_tag',
    html: '<html><head><style></style></head><body><h1>Test</h1></body></html>',
    expected: '<html><head><style></style></head><body><h1>Test</h1></body></html>',
    options: InlineOptions(removeInlinedSelectors: true, keepStyleTags: true),
  ),
  DocumentCase(
    description: 'identical_element',
    html: '<html><head><style>\n        .text-right {\n            text-align: right;\n        }\n        .box {\n            border: 1px solid #000;\n        }\n        </style></head><body><div class="box"><p>Hello World</p><p class="text-right">Hello World on right</p><p class="text-right">Hello World on right</p></div></body></html>',
    expected: '<html><head></head><body><div class="box" style="border: 1px solid #000;"><p>Hello World</p><p class="text-right" style="text-align: right;">Hello World on right</p><p class="text-right" style="text-align: right;">Hello World on right</p></div></body></html>',
  ),
  DocumentCase(
    description: 'is_or_prefixed_by #1',
    html: '<html><head><style>[data-type|="thing"] {color: red;}</style></head><body><span data-type="thing">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'is_or_prefixed_by #2',
    html: '<html><head><style>[data-type|="thing"] {color: red;}</style></head><body><span data-type="thing-1">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing-1" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'contains',
    html: '<html><head><style>[data-type*="i"] {color: red;}</style></head><body><span data-type="thing">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'has_class_unicode',
    html: '<html><head><style>.тест {color: red}</style></head><body><span class="тест">1</span></body></html>',
    expected: '<html><head></head><body><span class="тест" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'has_class_short',
    html: '<html><head><style>.t {color: red}</style></head><body><span class="test">1</span></body></html>',
    expected: '<html><head></head><body><span class="test">1</span></body></html>',
  ),
  DocumentCase(
    description: 'has_class_multiple',
    html: '<html><head><style>.t {color: red}</style></head><body><span class="t e s t">1</span></body></html>',
    expected: '<html><head></head><body><span class="t e s t" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'ends_with',
    html: '<html><head><style>[data-type\$="ng"] {color: red;}</style></head><body><span data-type="thing">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'starts_with',
    html: '<html><head><style>[data-type^="th"] {color: red;}</style></head><body><span data-type="thing">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'one_of #1',
    html: '<html><head><style>[data-type~="thing1"] {color: red;}</style></head><body><span data-type="thing1 thing2">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing1 thing2" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'one_of #2',
    html: '<html><head><style>[data-type~="thing2"] {color: red;}</style></head><body><span data-type="thing1 thing2">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing1 thing2" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'equals #1',
    html: '<html><head><style>[data-type="thing"] {color: red;}</style></head><body><span data-type="thing">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'equals #2',
    html: '<html><head><style>[data-type = "thing"] {color: red;}</style></head><body><span data-type="thing">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'exists',
    html: '<html><head><style>[data-type] {color: red;}</style></head><body><span data-type="thing">1</span></body></html>',
    expected: '<html><head></head><body><span data-type="thing" style="color: red;">1</span></body></html>',
  ),
  DocumentCase(
    description: 'specificity',
    html: '<html><head><style>div,a,b,c,d,e,f,g,h,i,j { color: red; } .foo { color: blue; }</style></head><body><div class="foo"></div></body></html>',
    expected: '<html><head></head><body><div class="foo" style="color: blue;"></div></body></html>',
  ),
  DocumentCase(
    description: 'first_child_descendant_selector_complex_dom',
    html: '<html><head><style>h1 :first-child { color: red; }</style></head><body><h1><div><span>Hello World!</span></div><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><div style="color: red;"><span style="color: red;">Hello World!</span></div><p>foo</p><div class="barclass"><span style="color: red;">baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'last_child_descendant_selector',
    html: '<html><head><style>h1 :last-child { color: red; }</style></head><body><h1><div><span>Hello World!</span></div></h1></body></html>',
    expected: '<html><head></head><body><h1><div style="color: red;"><span style="color: red;">Hello World!</span></div></h1></body></html>',
  ),
  DocumentCase(
    description: 'first_child_descendant_selector',
    html: '<html><head><style>h1 :first-child { color: red; }</style></head><body><h1><div><span>Hello World!</span></div></h1></body></html>',
    expected: '<html><head></head><body><h1><div style="color: red;"><span style="color: red;">Hello World!</span></div></h1></body></html>',
  ),
  DocumentCase(
    description: 'child_with_first_child_and_unmatched_class_selector_complex_dom',
    html: '<html><head><style>h1 > .hello:first-child { color: green; }</style></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'child_with_first_child_and_class_selector_complex_dom',
    html: '<html><head><style>h1 > .hello:first-child { color: green; }</style></head><body><h1><span class="hello">Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span class="hello" style="color: green;">Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'nested_child_with_first_child_override_selector_complex_dom',
    html: '<html><head><style>div > div > * { color: green; } div > div > :first-child { color: red; }</style></head><body><div><div><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></div></div></body></html>',
    expected: '<html><head></head><body><div><div><span style="color: red;">Hello World!</span><p style="color: green;">foo</p><div class="barclass" style="color: green;"><span style="color: red;">baz</span>bar</div></div></div></body></html>',
  ),
  DocumentCase(
    description: 'child_with_first_and_last_child_override_selector',
    html: '<html><head><style>p > * { color: green; } p > :first-child:last-child { color: red; }</style></head><body><p><span>Hello World!</span></p></body></html>',
    expected: '<html><head></head><body><p><span style="color: red;">Hello World!</span></p></body></html>',
  ),
  DocumentCase(
    description: 'id_el_child_with_first_child_override_selector_complex_dom',
    html: '<html><head><style>#abc > * { color: green; } #abc > :first-child { color: red; }</style></head><body><div id="abc"><span class="cde">Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></div></body></html>',
    expected: '<html><head></head><body><div id="abc"><span class="cde" style="color: red;">Hello World!</span><p style="color: green;">foo</p><div class="barclass" style="color: green;"><span>baz</span>bar</div></div></body></html>',
  ),
  DocumentCase(
    description: 'child_with_first_child_override_selector_complex_dom',
    html: '<html><head><style>div > * { color: green; } div > :first-child { color: red; }</style></head><body><div><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></div></body></html>',
    expected: '<html><head></head><body><div><span style="color: red;">Hello World!</span><p style="color: green;">foo</p><div class="barclass" style="color: green;"><span style="color: red;">baz</span>bar</div></div></body></html>',
  ),
  DocumentCase(
    description: 'child_follow_by_last_child_selector_complex_dom',
    html: '<html><head><style>h1 > :last-child { color: red; }</style></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass" style="color: red;"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'parent_pseudo_selector #1',
    html: '<html><head><style>span:last-child span { color: red; }</style></head><body><h1><span><span>Hello World!</span></span></h1></body></html>',
    expected: '<html><head></head><body><h1><span><span style="color: red;">Hello World!</span></span></h1></body></html>',
  ),
  DocumentCase(
    description: 'parent_pseudo_selector #2',
    html: '<html><head><style>span:last-child > span { color: red; }</style></head><body><h1><span><span>Hello World!</span></span></h1></body></html>',
    expected: '<html><head></head><body><h1><span><span style="color: red;">Hello World!</span></span></h1></body></html>',
  ),
  DocumentCase(
    description: 'parent_pseudo_selector #3',
    html: '<html><head><style>span:last-child > span { color: red; }</style></head><body><h1><span><span>Hello World!</span></span><span>nope</span></h1></body></html>',
    expected: '<html><head></head><body><h1><span><span>Hello World!</span></span><span>nope</span></h1></body></html>',
  ),
  DocumentCase(
    description: 'multiple_pseudo_selectors #1',
    html: '<html><head><style>span:first-child:last-child { color: red; }</style></head><body><h1><span>Hello World!</span></h1></body></html>',
    expected: '<html><head></head><body><h1><span style="color: red;">Hello World!</span></h1></body></html>',
  ),
  DocumentCase(
    description: 'multiple_pseudo_selectors #2',
    html: '<html><head><style>span:first-child:last-child { color: red; }</style></head><body><h1><span>Hello World!</span><span>again!</span></h1></body></html>',
    expected: '<html><head></head><body><h1><span>Hello World!</span><span>again!</span></h1></body></html>',
  ),
  DocumentCase(
    description: 'last_child_selector',
    html: '<html><head><style>h1 > :last-child { color: red; }</style></head><body><h1><span>Hello World!</span></h1></body></html>',
    expected: '<html><head></head><body><h1><span style="color: red;">Hello World!</span></h1></body></html>',
  ),
  DocumentCase(
    description: 'child_follow_by_first_child_selector_complex_dom',
    html: '<html><head><style>h1 > :first-child { color: red; }</style></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span style="color: red;">Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'child_follow_by_first_child_selector_with_comments',
    html: '<html><head><style>h1 > :first-child { color: red; }</style></head><body><h1> <!-- enough said --><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1> <!-- enough said --><span style="color: red;">Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'child_follow_by_first_child_selector_with_white_spaces',
    html: '<html><head><style>h1 > :first-child { color: red; }</style></head><body><h1> <span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1> <span style="color: red;">Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'child_follow_by_adjacent_selector_complex_dom',
    html: '<html><head><style>h1 > span + p { color: red; }</style></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span>Hello World!</span><p style="color: red;">foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'unknown_pseudo_selector',
    html: '<html><head><style>h1 > span:css4-selector { color: red; }</style></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'adjacent_selector',
    html: '<html><head><style>h1 + h2 { color: red; }</style></head><body><h1>Hello World!</h1><h2>How are you?</h2></body></html>',
    expected: '<html><head></head><body><h1>Hello World!</h1><h2 style="color: red;">How are you?</h2></body></html>',
  ),
  DocumentCase(
    description: 'child_all_selector_complex_dom',
    html: '<html><head><style>h1 > * { color: red; }</style></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span style="color: red;">Hello World!</span><p style="color: red;">foo</p><div class="barclass" style="color: red;"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'child_selector_complex_dom',
    html: '<html><head><style>h1 > span { color: red; }</style></head><body><h1><span>Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
    expected: '<html><head></head><body><h1><span style="color: red;">Hello World!</span><p>foo</p><div class="barclass"><span>baz</span>bar</div></h1></body></html>',
  ),
  DocumentCase(
    description: 'nested_child_selector',
    html: '<html><head><style>div > h1 > span { color: red; }"</style></head><body><div><h1><span>Hello World!</span></h1></div></body></html>',
    expected: '<html><head></head><body><div><h1><span style="color: red;">Hello World!</span></h1></div></body></html>',
  ),
  DocumentCase(
    description: 'child_selector',
    html: '<html><head><style>h1 > span { color: red; }</style></head><body><h1><span>Hello World!</span></h1></body></html>',
    expected: '<html><head></head><body><h1><span style="color: red;">Hello World!</span></h1></body></html>',
  ),
  DocumentCase(
    description: 'descendant_selector',
    html: '<html><head><style>h1 span { color: red; }</style></head><body><h1><span>Hello World!</span></h1></body></html>',
    expected: '<html><head></head><body><h1><span style="color: red;">Hello World!</span></h1></body></html>',
  ),
  DocumentCase(
    description: 'combination_selector',
    html: '<html><head><style>h1#a.b { color: red; }</style></head><body><h1 id="a" class="b">Hello World!</h1></body></html>',
    expected: '<html><head></head><body><h1 class="b" id="a" style="color: red;">Hello World!</h1></body></html>',
  ),
  DocumentCase(
    description: 'conflicting_multiple_class_selector',
    html: '<html><head><style>h1.a.b { color: red; }</style></head><body><h1 class="a b">Hello World!</h1><h1 class="a">I should not be changed</h1></body></html>',
    expected: '<html><head></head><body><h1 class="a b" style="color: red;">Hello World!</h1><h1 class="a">I should not be changed</h1></body></html>',
  ),
  DocumentCase(
    description: 'multiple_class_selector',
    html: '<html><head><style>h1.a.b { color: red; }</style></head><body><h1 class="a b">Hello World!</h1></body></html>',
    expected: '<html><head></head><body><h1 class="a b" style="color: red;">Hello World!</h1></body></html>',
  ),
  DocumentCase(
    description: 'missing_link_descendant_selector',
    html: '<html><head><style>#a b i { color: red }</style></head><body><div id="a"><i>x</i></div></body></html>',
    expected: '<html><head></head><body><div id="a"><i>x</i></div></body></html>',
  ),
  DocumentCase(
    description: 'comma_specificity',
    html: '<html><head><style>i, i { color: red; } i { color: blue; }</style></head><body><i>howdy</i></body></html>',
    expected: '<html><head></head><body><i style="color: blue;">howdy</i></body></html>',
  ),
  DocumentCase(
    description: 'overwrite_comma',
    html: '<html><head><style>h1,h2,h3 {color: #000;}</style></head><body><h1 style="color: #fff">Foo</h1><h3 style="color: #fff">Foo</h3></body></html>',
    expected: '<html><head></head><body><h1 style="color: #fff">Foo</h1><h3 style="color: #fff">Foo</h3></body></html>',
  ),
];

/// Fragments upstream inlines, and what it expects back.
const upstreamFragmentCases = <FragmentCase>[
  FragmentCase(
    description: 'inline_fragment',
    html: '<main>\n<h1>Hello</h1>\n<section>\n<p>who am i</p>\n</section>\n</main>',
    css: '\np {\n    color: red;\n}\n\nh1 {\n    color: blue;\n}\n',
    expected: '<main>\n<h1 style="color: blue;">Hello</h1>\n<section>\n<p style="color: red;">who am i</p>\n</section>\n</main>',
  ),
  FragmentCase(
    description: 'inline_fragment_empty',
    html: '',
    css: '',
    expected: '',
  ),
];
