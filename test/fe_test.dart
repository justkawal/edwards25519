import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:edwards25519/edwards25519.dart';
import 'package:test/test.dart';
import 'dart:math';

import 'test_utils/test_utils.dart';

void main() {
  test('Test mul64 to mul128', () {
    BigInt a = 5.toBigInt;
    BigInt b = 5.toBigInt;
    Uint128 r = Uint128.mul64(a, b);
    expect(
      r.low.toString(),
      '0x19'.toBigInt().toString(),
      reason: 'lo-range wide mult failed',
    );
    expect(
      r.high.toString(),
      BigInt.zero.toString(),
      reason: 'lo-range wide mult failed',
    );

    a = 18014398509481983.toBigInt;
    b = 18014398509481983.toBigInt; // 2^54 - 1
    r = Uint128.mul64(a, b);
    expect(
      r.high.toString(),
      BigInt.parse('fffffffffff', radix: 16).toString(),
      reason: 'hi-range wide mult failed',
    );
    expect(
      r.low.toString(),
      BigInt.parse('ff80000000000001', radix: 16).toString(),
      reason: 'hi-range wide mult failed',
    );

    a = 1125899906842661.toBigInt;
    b = 2097155.toBigInt;
    r = Uint128.mul64(a, b)
      ..addMul64(a, b)
      ..addMul64(a, b)
      ..addMul64(a, b)
      ..addMul64(a, b);
    expect(r.low, '16888498990613035'.toBigInt());
    expect(r.high, '640'.toBigInt());
  });

  test('Test Equality', () {
    final x =
        Element(BigInt.one, BigInt.one, BigInt.one, BigInt.one, BigInt.one);
    final y = Element(BigInt.from(5), BigInt.from(4), BigInt.from(3),
        BigInt.from(2), BigInt.one);
    expect(x.equal(x), 1);
    expect(x.equal(y), 0);
  });

  test('Test Multiply Distributes Over Add', () {
    for (var i = 0; i < 9999; i++) {
      // random x from generated list
      final x = getRandomElement();

      // random y from generated list
      final y = getRandomElement();

      // random z from generated list
      final z = getRandomElement();

      // Compute t1 = (x+y)*z
      final t1 = Element.feZero();
      t1.add(x, y);
      t1.multiply(t1, z);

      // Compute t2 = x*z + y*z
      final t2 = Element.feZero();
      final t3 = Element.feZero();
      t2.multiply(x, z);
      t3.multiply(y, z);
      t2.add(t2, t3);

      expect(t1.equal(t2), 1);
      expect(isInBounds(t1) && isInBounds(t2), true);
    }
  });

  test('Test Invert', () {
    final x =
        Element(BigInt.one, BigInt.one, BigInt.one, BigInt.one, BigInt.one);
    final one = Element.feOne();
    Element xinv = Element.feZero();
    Element r = Element.feZero();

    xinv.invert(x);
    r
      ..multiply(x, xinv)
      ..reduce();

    expect(one.equal(r), 1);

    var randomBytes = generateRandomBytes(32);
    final bytes = Uint8List.fromList(randomBytes);

    x.setBytes(bytes);

    xinv.invert(x);
    r
      ..multiply(x, xinv)
      ..reduce();

    expect(one.equal(r), 1);

    final zero = Element.feZero();
    x.set(zero);
    xinv.invert(x);

    expect(xinv.equal(zero), 1);
  });

  test('Test Mult32', () {
    final random = Random.secure();
    for (var i = 0; i < 9999; i++) {
      // random x from generated list
      final x = getRandomElement();
      // random int y
      final y = random.nextInt(4294967296);

      final t1 = Element.feZero();

      for (var j = 0; j < 100; j++) {
        t1.mult32(x, y);
      }

      final ty = Element.feZero();
      ty.l0 = y.toBigInt.toUnsigned(64);

      final t2 = Element.feZero();
      for (var j = 0; j < 100; j++) {
        t2.multiply(x, ty);
      }
      expect(t1.equal(t2), 1);
      expect(isInBounds(t1) && isInBounds(t2), true);
    }
  });

  test('Test FeMul', () {
    for (var i = 0; i < 9999; i++) {
      // random a from generated list
      final a = getRandomElement();
      // random b from generated list
      final b = getRandomElement();

      final a1 = a;
      final a2 = a;

      final b1 = b;
      final b2 = b;
      a1.feMulGeneric(a1, b1);
      a2.multiply(a2, b2);

      expect(a1.equal(a2), 1);
      expect(isInBounds(a1) && isInBounds(a2), true);
    }
  });

  test('Test Decimal Constants', () {
    final sqrtM1String =
        '19681161376707505956807079304988542015446066515923890162744021073123829784752';
    final exp = Element.feZero();
    exp.fromDecimal(sqrtM1String);
    final expected = Element.sqrtM1();

    expect(expected.equal(exp), 1);
  });

  test('Test Sqrt Ratio', () {
    // From draft-irtf-cfrg-ristretto255-decaf448-00, Appendix A.4.

    final tests = <((String, String), int, String)>[
      // If u is 0, the function is defined to return (0, TRUE), even if v
      // is zero. Note that where used in this package, the denominator v
      // is never zero.
      (
        (
          "0000000000000000000000000000000000000000000000000000000000000000",
          "0000000000000000000000000000000000000000000000000000000000000000"
        ),
        1,
        "0000000000000000000000000000000000000000000000000000000000000000",
      ),
      // 0/1 == 0²
      (
        (
          "0000000000000000000000000000000000000000000000000000000000000000",
          "0100000000000000000000000000000000000000000000000000000000000000"
        ),
        1,
        "0000000000000000000000000000000000000000000000000000000000000000",
      ),
      // If u is non-zero and v is zero, defined to return (0, FALSE).
      (
        (
          "0100000000000000000000000000000000000000000000000000000000000000",
          "0000000000000000000000000000000000000000000000000000000000000000"
        ),
        0,
        "0000000000000000000000000000000000000000000000000000000000000000",
      ),
      // 2/1 is not square in this field.
      (
        (
          "0200000000000000000000000000000000000000000000000000000000000000",
          "0100000000000000000000000000000000000000000000000000000000000000"
        ),
        0,
        "3c5ff1b5d8e4113b871bd052f9e7bcd0582804c266ffb2d4f4203eb07fdb7c54",
      ),
      // 4/1 == 2²
      (
        (
          "0400000000000000000000000000000000000000000000000000000000000000",
          "0100000000000000000000000000000000000000000000000000000000000000"
        ),
        1,
        "0200000000000000000000000000000000000000000000000000000000000000",
      ),
      // 1/4 == (2⁻¹)² == (2^(p-2))² per Euler's theorem
      (
        (
          "0100000000000000000000000000000000000000000000000000000000000000",
          "0400000000000000000000000000000000000000000000000000000000000000"
        ),
        1,
        "f6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3f",
      ),
    ];

    for (final tt in tests) {
      final u = Element.feZero()
        ..setBytes(Uint8List.fromList(hex.decode(tt.$1.$1)));
      final v = Element.feZero()
        ..setBytes(Uint8List.fromList(hex.decode(tt.$1.$2)));

      final want = Element.feZero()
        ..setBytes(Uint8List.fromList(hex.decode(tt.$3)));

      final (got, wasSquare) = Element.feZero().sqrtRatio(u, v);
      expect(got.equal(want), 1);

      final expectedWasSquare = tt.$2;
      expect(wasSquare, expectedWasSquare);
    }
  });

  test('Test Select Swap', () {
    final a = Element(
        358744748052810.toBigInt,
        1691584618240980.toBigInt,
        977650209285361.toBigInt,
        1429865912637724.toBigInt,
        560044844278676.toBigInt);
    final b = Element(
        84926274344903.toBigInt,
        473620666599931.toBigInt,
        365590438845504.toBigInt,
        1028470286882429.toBigInt,
        2146499180330972.toBigInt);

    final Element c = Element.feZero()..select(a, b, 1);
    final Element d = Element.feZero()..select(a, b, 0);

    expect(c.equal(a), 1);
    expect(d.equal(b), 1);

    c.swap(d, 0);

    expect(c.equal(a), 1);
    expect(d.equal(b), 1);

    c.swap(d, 1);

    expect(c.equal(b), 1);
    expect(d.equal(a), 1);
  });

  test('Test Set Bytes Round Trip', () {
    for (var i = 0; i < 9999; i++) {
      var randomBytes = generateRandomBytes(32);
      final bytes = Uint8List.fromList(randomBytes);
      final fe = getRandomElement();

      fe.setBytes(bytes);

      // Mask the most significant bit as it's ignored by SetBytes. (Now
      // instead of earlier so we check the masking in SetBytes is working.)
      bytes[bytes.length - 1] &= ((1 << 7) - 1);

      final actual = bytes.toList();

      final expected = fe.Bytes().toList();

      expect(actual.toString(), expected.toString());
      expect(isInBounds(fe), true);
    }

    for (var i = 0; i < 9999; i++) {
      final fe = getRandomElement();
      final r = getRandomElement();

      r.setBytes(Uint8List.fromList(fe.Bytes()));

      // Intentionally not using Equal not to go through Bytes again.
      // Calling reduce because both Generate and SetBytes can produce
      // non-canonical representations.
      fe.reduce();
      r.reduce();
      expect(fe == r, true);
    }

    // Check some fixed vectors from dalek
    var tests = [
      (
        fe: Element(
            358744748052810.toBigInt,
            1691584618240980.toBigInt,
            977650209285361.toBigInt,
            1429865912637724.toBigInt,
            560044844278676.toBigInt),
        b: Uint8List.fromList([
          74,
          209,
          69,
          197,
          70,
          70,
          161,
          222,
          56,
          226,
          229,
          19,
          112,
          60,
          25,
          92,
          187,
          74,
          222,
          56,
          50,
          153,
          51,
          233,
          40,
          74,
          57,
          6,
          160,
          185,
          213,
          31
        ]),
      ),
      (
        fe: Element(
            84926274344903.toBigInt,
            473620666599931.toBigInt,
            365590438845504.toBigInt,
            1028470286882429.toBigInt,
            2146499180330972.toBigInt),
        b: Uint8List.fromList([
          199,
          23,
          106,
          112,
          61,
          77,
          216,
          79,
          186,
          60,
          11,
          118,
          13,
          16,
          103,
          15,
          42,
          32,
          83,
          250,
          44,
          57,
          204,
          198,
          78,
          199,
          253,
          119,
          146,
          172,
          3,
          122
        ]),
      )
    ];

    for (final tt in tests) {
      final b = tt.fe.Bytes();
      final fe = Element.feZero()..setBytes(tt.b);
      expect(b.toList().toString(), tt.b.toList().toString());
      expect(fe.equal(tt.fe), 1);
    }
  });

  test('Test Bytes Big Equivalence', () {
    for (var i = 0; i < 9999; i++) {
      final randomBytes = generateRandomBytes(32);
      final bytes = Uint8List.fromList(randomBytes);
      final fe = getRandomElement();
      final fe1 = getRandomElement();

      fe.setBytes(bytes);

      bytes[bytes.length - 1] &= (1 << 7) - 1; // mask the most significant bit
      bytes.swapEndianness(); // in-place swapping
      final b = bytes.toBigInt();
      fe1.fromBigInt(b);

      expect(fe.equal(fe1), 1);

      final buf = Uint8List(32);
      buf
        ..fillBytes(fe1.toBigInt())
        ..swapEndianness();
      final actual = fe.Bytes();

      expect(actual.toString(), buf.toString());
      expect(isInBounds(fe) && isInBounds(fe1), true);
    }
  });

  test('Test Consistency', () {
    final Element x = Element.fromInt(1, 1, 1, 1, 1);
    final Element x2 = Element.feZero()..multiply(x, x);
    final Element x2sq = Element.feZero()..square(x);

    expect(x2.equal(x2sq), 1);

    final randomBytes = generateRandomBytes(32);
    final bytes = Uint8List.fromList(randomBytes);

    x.setBytes(bytes);

    x2.multiply(x, x);
    x2sq.square(x);

    expect(x2.equal(x2sq), 1);
  });

  test('Test Set Wide Bytes', () {
    final BigInt bigP = (BigInt.one << 255) - BigInt.from(19);

    final randomBytes = generateRandomBytes(64);
    final bytes = Uint8List.fromList(randomBytes);
    final fe = getRandomElement();

    final fe1 = Element.feZero()..set(fe);

    expect(() => fe.setWideBytes(Uint8List(42)), throwsArgumentError);
    expect(() => fe.setWideBytes(bytes), returnsNormally);

    bytes.swapEndianness();
    final b = bytes.toBigInt() % bigP;
    fe1.fromBigInt(b);

    expect(fe.equal(fe1), 1);
    expect(isInBounds(fe) && isInBounds(fe1), true);
  });
}

///
/// ------- Helper Code -------
///

// weirdLimbs can be combined to generate a range of edge-case field elements.
// 0 and -1 are intentionally more weighted, as they combine well.

final generation51 = <BigInt>[
  BigInt.zero,
  BigInt.zero,
  BigInt.zero,
  BigInt.zero,
  BigInt.one,
  19.toBigInt - BigInt.one,
  19.toBigInt,
  BigInt.parse('2aaaaaaaaaaaa', radix: 16),
  BigInt.parse('5555555555555', radix: 16),
  (BigInt.one << 51) - 20.toBigInt,
  (BigInt.one << 51) - 19.toBigInt,
  (BigInt.one << 51) - BigInt.one,
  (BigInt.one << 51) - BigInt.one,
  (BigInt.one << 51) - BigInt.one,
  (BigInt.one << 51) - BigInt.one,
];

final generation52 = <BigInt>[
  BigInt.zero,
  BigInt.one,
  19.toBigInt - BigInt.one,
  19.toBigInt + BigInt.one,
  19.toBigInt,
  BigInt.parse('2aaaaaaaaaaaa', radix: 16),
  BigInt.parse('5555555555555', radix: 16),
  (BigInt.one << 51) - 20.toBigInt,
  (BigInt.one << 51) + 20.toBigInt,
  (BigInt.one << 51) - 19.toBigInt,
  (BigInt.one << 51) + 19.toBigInt,
  (BigInt.one << 51) - BigInt.one,
  (BigInt.one << 51) + BigInt.one,
  BigInt.one << 51,
  (BigInt.one << 52) - 19.toBigInt,
  (BigInt.one << 52) + 19.toBigInt,
  (BigInt.one << 52) - BigInt.one,
  (BigInt.one << 52) + BigInt.one,
];

Element getRandomElement() {
  final Random rand = Random(Random().nextInt(1000000));
  return Element(
    generation52[rand.nextInt(generation52.length)],
    generation51[rand.nextInt(generation51.length)],
    generation51[rand.nextInt(generation51.length)],
    generation51[rand.nextInt(generation51.length)],
    generation51[rand.nextInt(generation51.length)],
  );
}

/// isInBounds returns whether the element is within the expected bit size bounds
/// after a light reduction.
bool isInBounds(Element x) {
  return x.l0.bitLength <= 52 &&
      x.l1.bitLength <= 52 &&
      x.l2.bitLength <= 52 &&
      x.l3.bitLength <= 52 &&
      x.l4.bitLength <= 52;
}
