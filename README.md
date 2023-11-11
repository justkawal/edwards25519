# edwards25519

### edwards25519, where security meets simplicity in cryptography!!


[![codecov](https://codecov.io/gh/justkawal/edwards25519/graph/badge.svg?token=8FERML02AR)](https://codecov.io/gh/justkawal/edwards25519)
[![Licence](https://img.shields.io/badge/License-MIT-red.svg)](./LICENSE)
![GitHub contributors](https://img.shields.io/github/contributors/justkawal/edwards25519)
[![Github Repo Stars](https://img.shields.io/github/stars/justkawal/edwards25519)](https://github.com/justkawal/edwards25519/stargazers)
![GitHub Sponsors](https://img.shields.io/github/sponsors/justkawal)

```dart
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:edwards25519/edwards25519.dart';

void main() {
  final p1 = Point.zero()..setBytes(Uint8List.fromList(hex.decode('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')));

  final p2 = Point.zero()..setBytes(Uint8List.fromList(hex.decode('1200000000000000000000000000000000000000000000000000000000000080')));

  // if returns 1 then it is equal, 0 otherwise
  final isEqual = p1.equal(p2) == 1;
  print('isEqual: $isEqual');

  final res = hex.encode(p1.Bytes());
  // res: 1200000000000000000000000000000000000000000000000000000000000080
  print('res: $res');
}

```

This library implements the edwards25519 elliptic curve, exposing the necessary APIs to build a wide array of higher-level primitives.
Read the docs at [pub.dev/edwards25519](https://pub.dev/documentation/edwards25519/latest/).

Inspiration: [Go-edwards25519](https://github.com/FiloSottile/edwards25519)
