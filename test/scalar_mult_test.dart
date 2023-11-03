import 'package:edwards25519/edwards25519.dart';
import 'package:test/test.dart';

import 'test_utils/test_utils.dart';

void main() {
  group('Scalar Mult:', () {
    test('Test Scalar Mult Small Scalars', () {
      final Scalar z = Scalar();
      Point p = Point.zero();
      p.scalarMult(z, Point.newGeneratorPoint());

      expect(p.equal(Point.identity), 1);

      checkOnCurve([p]);

      final scEight = Scalar()
        ..setCanonicalBytes(<int>[
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
        ]);

      p = Point.zero();
      p.scalarMult(scEight, Point.newGeneratorPoint());
      expect(p.equal(Point.newGeneratorPoint()), 1);

      checkOnCurve([p]);
    });

    test('Test Scalar Mult Vs Dalek', () {
      final Point p = Point.zero()
        ..scalarMult(dalekScalar, Point.newGeneratorPoint());

      expect(p.equal(dalekScalarBasepoint), 1);
      checkOnCurve([p]);
    });

    test('Test Base Mult Vs Dalek', () {
      final Point p = Point.zero()..scalarBaseMult(dalekScalar);
      expect(p.equal(dalekScalarBasepoint), 1);

      checkOnCurve([p]);
    });

    test('Test Var Time Double Base Mult Vs Dalek', () {
      Point p = Point.zero();
      Scalar z = Scalar();
      p.varTimeDoubleScalarBaseMult(dalekScalar, Point.newGeneratorPoint(), z);
      expect(p.equal(dalekScalarBasepoint), 1);

      checkOnCurve([p]);

      p = Point.zero();
      p.varTimeDoubleScalarBaseMult(z, Point.newGeneratorPoint(), dalekScalar);
      expect(p.equal(dalekScalarBasepoint), 1);

      checkOnCurve([p]);
    });

    test('Test Scalar Mult Distributes Over Add', () {
      for (int i = 0; i < 100; i++) {
        final x = generateScalar();
        final y = generateScalar();
        final Scalar z = Scalar();

        z.add(x, y);

        final Point p = Point.zero()..scalarMult(x, Point.newGeneratorPoint());
        final Point q = Point.zero()..scalarMult(y, Point.newGeneratorPoint());
        final Point r = Point.zero()..scalarMult(z, Point.newGeneratorPoint());
        final Point check = Point.zero()..add(p, q);

        checkOnCurve([p, q, r, check]);
        expect(check.equal(r), 1);
      }
    });

    test('Test Scalar Mult Non Identity Point', () {
      // Check whether p.ScalarMult and q.ScalaBaseMult give the same,
      // when p and q are originally set to the base point.

      for (int i = 0; i < 100; i++) {
        final x = generateScalar();
        final Point p = Point.zero()..set(Point.newGeneratorPoint());
        final Point q = Point.zero()..set(Point.newGeneratorPoint());

        p.scalarMult(x, Point.newGeneratorPoint());
        q.scalarBaseMult(x);

        checkOnCurve([p, q]);
        expect(p.equal(q), 1);
      }
    });

    test('Test Basepoint Table Generation', () {
      // The basepoint table is 32 affineLookupTables,
      // corresponding to (16^2i)*B for table i.
      final basepointTable =
          List<affineLookupTable>.from(basepointTablePrecomp.instance.table);

      final tmp1 = projP1xP1.zero();
      final tmp2 = projP2.zero();
      final tmp3 = Point.zero();
      tmp3.set(Point.generator);
      final table =
          List<affineLookupTable>.generate(32, (_) => affineLookupTable());
      for (int i = 0; i < 32; i++) {
        // Build the table
        table[i].fromP3(tmp3);

        expect(table[i] == basepointTable[i], true);

        // Set p = (16^2)*p = 256*p = 2^8*p
        tmp2.fromP3(tmp3);
        for (int j = 0; j < 7; j++) {
          tmp1.double(tmp2);
          tmp2.fromP1xP1(tmp1);
        }
        tmp1.double(tmp2);
        tmp3.fromP1xP1(tmp1);
        checkOnCurve([tmp3]);
      }
    });

    test('Test Scalar Mult Matches Base Mult', () {
      for (int i = 0; i < 100; i++) {
        final Scalar x = generateScalar();
        final Point p = Point.zero()..scalarMult(x, Point.generator);
        final Point q = Point.zero()..scalarBaseMult(x);

        checkOnCurve([p, q]);
        expect(p.equal(q), 1);
      }
    });

    test('Test Basepoint Naf Table Generation', () {
      final table = nafLookupTable8();
      table.fromP3(Point.generator);

      expect(table == basepointNafTablePrecomp.instance.table, true);
    });

    test('Test Var Time Double Base Mult Matches Base Mult', () {
      for (int i = 0; i < 100; i++) {
        final x = generateScalar();
        final y = generateScalar();
        final p = Point.zero()
          ..varTimeDoubleScalarBaseMult(x, Point.generator, y);
        final q1 = Point.zero()..scalarBaseMult(x);
        final q2 = Point.zero()..scalarBaseMult(y);
        final check = Point.zero()..add(q1, q2);

        checkOnCurve([p, check, q1, q2]);
        p.equal(check) == 1;
      }
    });
  });
}
