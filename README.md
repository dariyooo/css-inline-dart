# css_inline_dart

A dart package to inline CSS styles into HTML content using Rust and Native Assets.

## Usage

```dart
import 'package:css_inline_dart/css_inline_dart.dart';

// Synchronous
final inlined = inlineCssSync(html: '<html>...</html>');

// Asynchronous wrapper
final inlinedAsync = await inlineCss(html: '<html>...</html>');
```

## Development

### Update Rust Code
If you modify the functions in `rust/src/lib.rs`:

1. Update the C header in `rust/include/css_inline_dart.h` to match your changes.
2. Regenerate Dart bindings:
   ```bash
   dart run ffigen --config ffigen.yaml
   ```
3. Build and test:
   ```bash
   dart run test
   ```
