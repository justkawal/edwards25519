import 'dart:math';
import 'dart:typed_data';
import 'package:edwards25519/edwards25519.dart';

// a random scalar generated using dalek.
final dalekScalar = Scalar()
  ..setCanonicalBytes(<int>[
    219,
    106,
    114,
    9,
    174,
    249,
    155,
    89,
    69,
    203,
    201,
    93,
    92,
    116,
    234,
    187,
    78,
    115,
    103,
    172,
    182,
    98,
    62,
    103,
    187,
    136,
    13,
    100,
    248,
    110,
    12,
    4
  ]);
// the above, times the edwards25519 basepoint.
final dalekScalarBasepoint = Point.zero()
  ..setBytes(Uint8List.fromList(<int>[
    0xf4,
    0xef,
    0x7c,
    0xa,
    0x34,
    0x55,
    0x7b,
    0x9f,
    0x72,
    0x3b,
    0xb6,
    0x1e,
    0xf9,
    0x46,
    0x9,
    0x91,
    0x1c,
    0xb9,
    0xc0,
    0x6c,
    0x17,
    0x28,
    0x2d,
    0x8b,
    0x43,
    0x2b,
    0x5,
    0x18,
    0x6a,
    0x54,
    0x3e,
    0x48
  ]));

// generate random bytes
Uint8List generateRandomBytes(int length) {
  return Uint8List.fromList(List<int>.generate(length, (_) => Random().nextInt(256)));
}

final scOneBytes = List.generate(32, (index) => index == 0 ? 1 : 0);
final scOne = Scalar()..setCanonicalBytes(scOneBytes);
final scMinusOne = Scalar()..setCanonicalBytes(Scalar.scalarMinusOneBytes);

/// Generate returns a valid (reduced modulo l) Scalar with a distribution
/// weighted towards high, low, and edge values.
Scalar generateScalar() {
  final diceRoll = Random().nextInt(100);
  var s = List<int>.filled(32, 0);
  switch (diceRoll) {
    case 0:
    case 1:
      s = List<int>.from(scOneBytes);
    case 2:
      s = List<int>.from(Scalar.scalarMinusOneBytes);
    default:
      if (diceRoll < 5) {
        // Generate a low scalar in [0, 2^125).
        for (var i = 0; i < 16; i++) {
          s[i] = Random().nextInt(256);
        }
        s[15] &= (1 << 5) - 1;
      } else if (diceRoll < 10) {
        // Generate a high scalar in [2^252, 2^252 + 2^124).
        s[31] = 1 << 4;
        for (var i = 0; i < 16; i++) {
          s[i] = Random().nextInt(256);
        }
        s[15] &= (1 << 4) - 1;
      } else {
        // Generate a valid scalar in [0, l) by returning [0, 2^252) which has a
        // negligibly different distribution (the former has a 2^-127.6 chance
        // of being out of the latter range).
        for (var i = 0; i < 32; i++) {
          s[i] = Random().nextInt(256);
        }
        s[31] &= (1 << 4) - 1;
      }
  }

  final val = Scalar();
  fiatScalarFromBytes(val.s, s);
  fiatScalarToMontgomery(val.s, val.s);
  return val;
}
