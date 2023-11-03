import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:edwards25519/edwards25519.dart';
import 'package:test/test.dart';

import 'test_utils/test_utils.dart';

void main() {
  test('Test Scalar Generate', () {
    for (var i = 0; i < 10240; i++) {
      final s = generateScalar();
      expect(Scalar.isReduced(s.Bytes()), true);
    }
  });

  test('SetCanonicalBytes correctly reduces scalars', () {
    for (var i = 0; i < 10240; i++) {
      final sc = generateScalar();

      final bytes = generateRandomBytes(32);
      // Mask out top 4 bits to guarantee value falls in [0, l).
      bytes[bytes.length - 1] &= (1 << 4) - 1;

      expect(() => sc.setCanonicalBytes(bytes), returnsNormally);
      final repr = sc.Bytes();
      // compare list equality
      expect(repr, bytes);
      expect(Scalar.isReduced(repr), true);
    }
  });

  test('SetCanonicalBytes correctly sets Canonical Bytes', () {
    for (var i = 0; i < 10240; i++) {
      final sc1 = generateScalar();
      final sc2 = Scalar();

      expect(() => sc2.setCanonicalBytes(sc1.Bytes()), returnsNormally);
      expect(sc1.s, sc2.s);
      expect(sc1.equal(sc2), 1);
    }
  });

  test('SetCanonicalBytes rejects invalid bytes', () {
    final b = List<int>.from(Scalar.scalarMinusOneBytes);
    b[31] += 1;
    final s = Scalar.from(scOne);
    expect(() => s.setCanonicalBytes(b), throwsArgumentError);

    // s and scOne should be equal because above should have failed and not modified s.
    expect(s.equal(scOne), 1);
  });

  test('Test Scalar Multiply Distributes Over Add', () {
    for (var index = 0; index < 12397; index++) {
      // Compute t1 = (x+y)*z
      final x = generateScalar();
      final y = generateScalar();
      final z = generateScalar();

      final Scalar t1 = Scalar();
      t1.add(x, y);
      t1.multiply(t1, z);

      // Compute t2 = x*z + y*z
      final Scalar t2 = Scalar();
      final Scalar t3 = Scalar();
      t2.multiply(x, z);
      t3.multiply(y, z);
      t2.add(t2, t3);

      final (t1Bytes, t2Bytes) = (t1.Bytes(), t2.Bytes());

      expect(t1.equal(t2), 1);
      expect(Scalar.isReduced(t1Bytes) && Scalar.isReduced(t2Bytes), true);
    }
  });

  test('Test Scalar Add Like Sub Neg', () {
    for (var index = 0; index < 10240; index++) {
      // Compute t1 = x - y
      final x = generateScalar();
      final y = generateScalar();

      final t1 = Scalar();
      t1.subtract(x, y);

      // Compute t2 = -y + x
      final Scalar t2 = Scalar();
      t2.negate(y);
      t2.add(t2, x);

      expect(t1.equal(t2), 1);
      expect(
          Scalar.isReduced(t1.Bytes()) && Scalar.isReduced(t2.Bytes()), true);
    }
  });

  test('Test Scalar NonAdjacent Form', () {
    final s = Scalar()
      ..setCanonicalBytes([
        0x1a,
        0x0e,
        0x97,
        0x8a,
        0x90,
        0xf6,
        0x62,
        0x2d,
        0x37,
        0x47,
        0x02,
        0x3f,
        0x8a,
        0xd8,
        0x26,
        0x4d,
        0xa7,
        0x58,
        0xaa,
        0x1b,
        0x88,
        0xe0,
        0x40,
        0xd1,
        0x58,
        0x9e,
        0x7b,
        0x7f,
        0x23,
        0x76,
        0xef,
        0x09,
      ]);

    final expectedNaf = [
      0,
      13,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      7,
      0,
      0,
      0,
      0,
      0,
      0,
      -9,
      0,
      0,
      0,
      0,
      -11,
      0,
      0,
      0,
      0,
      3,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      9,
      0,
      0,
      0,
      0,
      -5,
      0,
      0,
      0,
      0,
      0,
      0,
      3,
      0,
      0,
      0,
      0,
      11,
      0,
      0,
      0,
      0,
      11,
      0,
      0,
      0,
      0,
      0,
      -9,
      0,
      0,
      0,
      0,
      0,
      -3,
      0,
      0,
      0,
      0,
      9,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      0,
      -1,
      0,
      0,
      0,
      0,
      0,
      9,
      0,
      0,
      0,
      0,
      -15,
      0,
      0,
      0,
      0,
      -7,
      0,
      0,
      0,
      0,
      -9,
      0,
      0,
      0,
      0,
      0,
      5,
      0,
      0,
      0,
      0,
      13,
      0,
      0,
      0,
      0,
      0,
      -3,
      0,
      0,
      0,
      0,
      -11,
      0,
      0,
      0,
      0,
      -7,
      0,
      0,
      0,
      0,
      -13,
      0,
      0,
      0,
      0,
      11,
      0,
      0,
      0,
      0,
      -9,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      -15,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      7,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      5,
      0,
      0,
      0,
      0,
      0,
      13,
      0,
      0,
      0,
      0,
      0,
      0,
      11,
      0,
      0,
      0,
      0,
      0,
      15,
      0,
      0,
      0,
      0,
      0,
      -9,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      -1,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      7,
      0,
      0,
      0,
      0,
      0,
      -15,
      0,
      0,
      0,
      0,
      0,
      15,
      0,
      0,
      0,
      0,
      15,
      0,
      0,
      0,
      0,
      15,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
    ];

    final sNaf = s.nonAdjacentForm(5).toList();
    expect(sNaf, expectedNaf);
  });

  test('Test Scalar Equal', () {
    if (scOne.equal(scMinusOne) == 1) {
      throw Exception("scOne.equal(scMinusOne) is true");
    }
    if (scMinusOne.equal(scMinusOne) == 0) {
      throw Exception("scMinusOne.equal(scMinusOne) is false");
    }
  });

  test('Test Scalar Set Uniform Bytes', () {
    BigInt mod =
        BigInt.parse("27742317777372353535851937790883648493", radix: 10);
    mod += BigInt.one << 252;

    for (var i = 0; i < 10240; i++) {
      final sc = generateScalar();

      // generate random bytes
      final bytes = generateRandomBytes(64);
      sc.setUniformBytes(bytes);
      final repr = sc.Bytes();
      expect(Scalar.isReduced(repr), true);
      final scBig = (repr..swapEndianness()).toBigInt();
      final inBig = (bytes..swapEndianness()).toBigInt();

      expect(inBig % mod == scBig, true);
    }
  });

  test('Test Scalar Set Bytes With Clamping', () {
    // Generated with libsodium.js 1.0.18 crypto_scalarmult_ed25519_base.
    {
      final random =
          '633d368491364dc9cd4c1bf891b1d59460face1644813240a313e61f2c88216e';
      final s = Scalar()..setBytesWithClamping(hex.decode(random));
      final p = Point.zero()..scalarBaseMult(s);
      final want =
          '1d87a9026fd0126a5736fe1628c95dd419172b5b618457e041c9c861b2494a94';
      final got = hex.encode(p.Bytes());
      expect(got, want);
    }
    {
      final zero =
          '0000000000000000000000000000000000000000000000000000000000000000';
      final s = Scalar()..setBytesWithClamping(hex.decode(zero));
      final p = Point.zero()..scalarBaseMult(s);
      final want =
          '693e47972caf527c7883ad1b39822f026f47db2ab0e1919955b8993aa04411d1';
      final got = hex.encode(p.Bytes());
      expect(got, want);
    }

    {
      final one =
          'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
      final s = Scalar()..setBytesWithClamping(hex.decode(one));
      final p = Point.zero()..scalarBaseMult(s);
      final want =
          '12e9a68b73fd5aacdbcaf3e88c46fea6ebedb1aa84eed1842f07f8edab65e3a7';
      final got = hex.encode(p.Bytes());
      expect(got, want);
    }
  });

  test('Bytes Montogomery', () {
    final String publicKey =
        '3bf918ffc2c955dc895bf145f566fb96623c1cadbe040091175764b5fde322c0';
    final Point p = Point.zero()
      ..setBytes(Uint8List.fromList(hex.decode(publicKey)));

    final String expected =
        'efc6c9d0738e9ea18d738ad4a2653631558931b0f1fde4dd58c436d19686dc28';
    final String got = hex.encode(p.BytesMontgomery());
    expect(got, expected);
  });

  test('Test Bytes Montgomery Infinity', () {
    final p = Point.identity;
    final String want =
        '0000000000000000000000000000000000000000000000000000000000000000';
    final String got = hex.encode(p.BytesMontgomery());
    expect(got, want);
  });

  test('Test Mult By Cofactor', () {
    final String lowOrderBytes =
        '26e8958fc2b227b045c3f489f2ef98f0d5dfac05d3c63339b13802886d53fc85';
    final lowOrder = Point.zero()
      ..setBytes(Uint8List.fromList(hex.decode(lowOrderBytes)));

    final got = Point.zero()..multByCofactor(lowOrder);

    expect(got.equal(Point.identity), 1);
  });

  test('Test Mult By Cofactor', () {
    final String lowOrderBytes =
        '26e8958fc2b227b045c3f489f2ef98f0d5dfac05d3c63339b13802886d53fc85';
    final lowOrder = Point.zero()
      ..setBytes(Uint8List.fromList(hex.decode(lowOrderBytes)));

    for (int i = 0; i < 1024; i++) {
      final scalar = generateRandomBytes(64);
      final s = Scalar()..setUniformBytes(scalar);
      final p = Point.zero()..scalarBaseMult(s);
      final p8 = Point.zero()..multByCofactor(p);
      checkOnCurve([p8]);

      // 8 * p == (8 * s) * B
      final reprEight = <int>[
        8,
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
      ];
      final scEight = Scalar()..setCanonicalBytes(reprEight);
      s.multiply(s, scEight);
      final pp = Point.zero()..scalarBaseMult(s);

      expect(p8.equal(pp), 1);

      // 8 * p == 8 * (lowOrder + p)
      pp.add(p, lowOrder);
      pp.multByCofactor(pp);

      expect(p8.equal(pp), 1);

      // 8 * p == p + p + p + p + p + p + p + p
      pp.set(Point.identity);
      for (int i = 0; i < 8; i++) {
        pp.add(pp, p);
      }

      expect(p8.equal(pp), 1);
    }
  });
  test('Test Scalar Invert', () {
    for (int i = 0; i < 1024; i++) {
      final xInv = generateScalar();
      final x = generateScalar();

      xInv.Invert(x);
      Scalar check = Scalar()..multiply(x, xInv);

      expect(check.equal(scOne), 1);
      expect(Scalar.isReduced(xInv.Bytes()), true);
    }

    final randomScalar = dalekScalar;
    final randomInverse = Scalar()..Invert(randomScalar);
    Scalar check = Scalar()..multiply(randomScalar, randomInverse);

    expect(check.equal(scOne), 1);
    expect(Scalar.isReduced(randomInverse.Bytes()), true);

    final zero = Scalar();
    final xx = Scalar()..Invert(zero);

    expect(xx.equal(zero), 1);
  });

  test('Test Multi Scalar Mult Matches Base Mult', () {
    for (int i = 0; i < 124; i++) {
      final x = generateScalar();
      final y = generateScalar();
      final z = generateScalar();
      final Point p = Point.zero()
        ..multiScalarMult(
            [x, y, z], [Point.generator, Point.generator, Point.generator]);

      final Point q1 = Point.zero()..scalarBaseMult(x);
      final Point q2 = Point.zero()..scalarBaseMult(y);
      final Point q3 = Point.zero()..scalarBaseMult(z);
      final Point check = Point.zero()..add(q1, q2);
      check.add(check, q3);

      checkOnCurve([p, check, q1, q2, q3]);
      expect(p.equal(check), 1);
    }
  });

  test('Test Var Time Multi Scalar Mult Matches Base Mult', () {
    for (int i = 0; i < 124; i++) {
      final x = generateScalar();
      final y = generateScalar();
      final z = generateScalar();
      final Point p = Point.zero()
        ..varTimeMultiScalarMult(
            [x, y, z], [Point.generator, Point.generator, Point.generator]);

      final Point q1 = Point.zero()..scalarBaseMult(x);
      final Point q2 = Point.zero()..scalarBaseMult(y);
      final Point q3 = Point.zero()..scalarBaseMult(z);
      final Point check = Point.zero()..add(q1, q2);
      check.add(check, q3);

      checkOnCurve([p, check, q1, q2, q3]);
      expect(p.equal(check), 1);
    }
  });
}
