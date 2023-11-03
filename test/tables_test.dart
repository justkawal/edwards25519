import 'package:edwards25519/edwards25519.dart';
import 'package:test/test.dart';

void main() {
  group('Tables Test', () {
    test('Proj Lookup Table', () {
      final projLookupTable table = projLookupTable()..fromP3(Point.generator);

      final projCached tmp1 = projCached.zero();
      final projCached tmp2 = projCached.zero();
      final projCached tmp3 = projCached.zero();
      table.selectInto(tmp1, 6);
      table.selectInto(tmp2, -2);
      table.selectInto(tmp3, -4);
      // Expect T1 + T2 + T3 = identity

      projP1xP1 accP1xP1 = projP1xP1.zero();
      final accP3 = Point.identity;

      accP1xP1.add(accP3, tmp1);
      accP3.fromP1xP1(accP1xP1);
      accP1xP1.add(accP3, tmp2);
      accP3.fromP1xP1(accP1xP1);
      accP1xP1.add(accP3, tmp3);
      accP3.fromP1xP1(accP1xP1);

      expect(accP3.equal(Point.identity), 1);
    });

    test('Affine Lookup Table', () {
      final affineLookupTable table = affineLookupTable()
        ..fromP3(Point.generator);

      final affineCached tmp1 = affineCached.zero();
      final affineCached tmp2 = affineCached.zero();
      final affineCached tmp3 = affineCached.zero();
      table.selectInto(tmp1, 3);
      table.selectInto(tmp2, -7);
      table.selectInto(tmp3, 4);
      // Expect T1 + T2 + T3 = identity

      projP1xP1 accP1xP1 = projP1xP1.zero();
      final accP3 = Point.identity;

      accP1xP1.addAffine(accP3, tmp1);
      accP3.fromP1xP1(accP1xP1);
      accP1xP1.addAffine(accP3, tmp2);
      accP3.fromP1xP1(accP1xP1);
      accP1xP1.addAffine(accP3, tmp3);
      accP3.fromP1xP1(accP1xP1);

      expect(accP3.equal(Point.identity), 1);
    });

    test('Naf Lookup Table 5', () {
      final table = nafLookupTable5()..fromP3(Point.generator);

      final tmp1 = projCached.zero();
      final tmp2 = projCached.zero();
      final tmp3 = projCached.zero();
      final tmp4 = projCached.zero();
      table.selectInto(tmp1, 9);
      table.selectInto(tmp2, 11);
      table.selectInto(tmp3, 7);
      table.selectInto(tmp4, 13);
      // Expect T1 + T2 = T3 + T4

      projP1xP1 accP1xP1 = projP1xP1.zero();
      final lhs = Point.identity;
      final rhs = Point.identity;

      accP1xP1.add(lhs, tmp1);
      lhs.fromP1xP1(accP1xP1);
      accP1xP1.add(lhs, tmp2);
      lhs.fromP1xP1(accP1xP1);

      accP1xP1.add(rhs, tmp3);
      rhs.fromP1xP1(accP1xP1);
      accP1xP1.add(rhs, tmp4);
      rhs.fromP1xP1(accP1xP1);

      expect(lhs.equal(rhs), 1);
    });

    test('Naf Lookup Table 8', () {
      final table = nafLookupTable8()..fromP3(Point.generator);

      final tmp1 = affineCached.zero();
      final tmp2 = affineCached.zero();
      final tmp3 = affineCached.zero();
      final tmp4 = affineCached.zero();
      table.selectInto(tmp1, 49);
      table.selectInto(tmp2, 11);
      table.selectInto(tmp3, 35);
      table.selectInto(tmp4, 25);
      // Expect T1 + T2 = T3 + T4

      projP1xP1 accP1xP1 = projP1xP1.zero();
      final lhs = Point.identity;
      final rhs = Point.identity;

      accP1xP1.addAffine(lhs, tmp1);
      lhs.fromP1xP1(accP1xP1);
      accP1xP1.addAffine(lhs, tmp2);
      lhs.fromP1xP1(accP1xP1);

      accP1xP1.addAffine(rhs, tmp3);
      rhs.fromP1xP1(accP1xP1);
      accP1xP1.addAffine(rhs, tmp4);
      rhs.fromP1xP1(accP1xP1);

      expect(lhs.equal(rhs), 1);
    });
  });
}
