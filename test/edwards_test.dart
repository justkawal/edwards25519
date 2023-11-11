import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:edwards25519/edwards25519.dart';
import 'package:test/test.dart';

final G = Point.generator;
final I = Point.identity;

void main() {
  test('Test Identity Point', () {
    // identity is the point at infinity.
    final identity = Point.zero()
      ..setBytes(Uint8List.fromList([
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]));

    final identity2 = Point.identity;

    expect(identity.x.equal(identity2.x), 1);
    expect(identity.y.equal(identity2.y), 1);
    expect(identity.z.equal(identity2.z), 1);
    expect(identity.t.equal(identity2.t), 1);
  });

  test('Test Generator Point', () {
    final generator = Point.zero()
      ..setBytes(Uint8List.fromList([
        0x58,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66
      ]));

    final generator2 = Point.generator;

    expect(generator.x.equal(generator2.x), 1);
    expect(generator.y.equal(generator2.y), 1);
    expect(generator.z.equal(generator2.z), 1);
    expect(generator.t.equal(generator2.t), 1);
  });

  test('Test Generator', () {
    // These are the coordinates of B from RFC 8032, Section 5.1, converted to
    // little endian hex.
    final x =
        '1ad5258f602d56c9b2a7259560c72c695cdcd6fd31e2a4c0fe536ecdd3366921';
    final y =
        '5866666666666666666666666666666666666666666666666666666666666666';

    expect(hex.encode(G.x.Bytes()), x);
    expect(hex.encode(G.y.Bytes()), y);
    expect(G.z.equal(Element.feOne()), 1);

    // Check on curve.
    checkOnCurve([G]);
  });

  test('Test add, subtract, negate on Base Point', () {
    final (checkLhs, checkRhs) = (Point.zero(), Point.zero());

    checkLhs.add(G, G);
    final tmpP2 = projP2.fromP3(G);
    final tmpP1xP1 = projP1xP1.zero()..double(tmpP2);
    checkRhs.fromP1xP1(tmpP1xP1);

    expect(checkLhs.equal(checkRhs), 1, reason: 'B + B != [2]B');

    checkOnCurve([checkLhs, checkRhs]);

    checkLhs.subtract(G, G);
    final Bneg = Point.zero()..negate(G);
    checkRhs.add(G, Bneg);

    expect(checkLhs.equal(checkRhs), 1, reason: 'B - B != B + (-B)');

    expect(I.equal(checkLhs), 1, reason: 'B - B != 0');

    expect(I.equal(checkRhs), 1, reason: 'B + (-B) != 0');

    checkOnCurve([checkLhs, checkRhs, Bneg]);
  });

  test('Test Equality', () {
    Point t = Point.zero();
    expect(t == t, false, reason: 'Ouch, Equality check enabled.');
  });

  test('Test Invalid Encodings', () {
    // An invalid point, that also happens to have y > p.
    final invalid =
        'efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f';
    final p = Point.newGeneratorPoint();

    expect(() => p.setBytes(Uint8List.fromList(hex.decode(invalid))),
        throwsException);

    expect(p.equal(G), 1,
        reason:
            'The generator point `p` was mistakenly modified on invalid bytes.');

    checkOnCurve([p]);
  });

  group('Test Non Canonical Points', () {
    final tests = <(String, String, String)>[
      // Points with x = 0 and the sign bit set. With x = 0 the curve equation
      // gives y² = 1, so y = ±1. 1 has two valid encodings.
      (
        "y=1,sign-",
        "0100000000000000000000000000000000000000000000000000000000000080",
        "0100000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+1,sign-",
        "eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0100000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p-1,sign-",
        "ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "ecffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
      ),
      // Non-canonical y encodings with values 2²⁵⁵-19 (p) to 2²⁵⁵-1 (p+18).
      (
        "y=p,sign+",
        "edffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0000000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p,sign-",
        "edffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0000000000000000000000000000000000000000000000000000000000000080",
      ),
      (
        "y=p+1,sign+",
        "eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0100000000000000000000000000000000000000000000000000000000000000",
      ),
      // "y=p+1,sign-" is already tested above.
      // p+2 is not a valid y-coordinate.
      (
        "y=p+3,sign+",
        "f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0300000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+3,sign-",
        "f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0300000000000000000000000000000000000000000000000000000000000080",
      ),
      (
        "y=p+4,sign+",
        "f1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0400000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+4,sign-",
        "f1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0400000000000000000000000000000000000000000000000000000000000080",
      ),
      (
        "y=p+5,sign+",
        "f2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0500000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+5,sign-",
        "f2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0500000000000000000000000000000000000000000000000000000000000080",
      ),
      (
        "y=p+6,sign+",
        "f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0600000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+6,sign-",
        "f3ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0600000000000000000000000000000000000000000000000000000000000080",
      ),

      // p+7 is not a valid y-coordinate.
      // p+8 is not a valid y-coordinate.

      (
        "y=p+9,sign+",
        "f6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0900000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+9,sign-",
        "f6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0900000000000000000000000000000000000000000000000000000000000080",
      ),
      (
        "y=p+10,sign+",
        "f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0a00000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+10,sign-",
        "f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0a00000000000000000000000000000000000000000000000000000000000080",
      ),

      // p+11 is not a valid y-coordinate.
      // p+12 is not a valid y-coordinate.
      // p+13 is not a valid y-coordinate.

      (
        "y=p+14,sign+",
        "fbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0e00000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+14,sign-",
        "fbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0e00000000000000000000000000000000000000000000000000000000000080",
      ),
      (
        "y=p+15,sign+",
        "fcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "0f00000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+15,sign-",
        "fcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "0f00000000000000000000000000000000000000000000000000000000000080",
      ),
      (
        "y=p+16,sign+",
        "fdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "1000000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+16,sign-",
        "fdffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "1000000000000000000000000000000000000000000000000000000000000080",
      ),

      // p+17 is not a valid y-coordinate.

      (
        "y=p+18,sign+",
        "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
        "1200000000000000000000000000000000000000000000000000000000000000",
      ),
      (
        "y=p+18,sign-",
        "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        "1200000000000000000000000000000000000000000000000000000000000080",
      ),
    ];
    for (final value in tests) {
      test(value.$1, () {
        final p1 = Point.zero()
          ..setBytes(Uint8List.fromList(hex.decode(value.$2)));

        final p2 = Point.zero()
          ..setBytes(Uint8List.fromList(hex.decode(value.$3)));

        expect(p1.equal(p2), 1, reason: 'Points p1 and p2 are not equal.');
        expect(hex.encode(p1.Bytes()), value.$3,
            reason:
                'Encoding again should have produced the correct canonical');
        checkOnCurve([p1, p2]);
      });
    }
  });
}
