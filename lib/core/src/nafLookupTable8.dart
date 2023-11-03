part of edwards25519;

/// A dynamic lookup table for variable-base, constant-time scalar muls.
class nafLookupTable8 {
  final List<affineCached> points =
      List.generate(64, (_) => affineCached.zero());

  /// This is not optimised for speed; fixed-base tables should be precomputed.
  void fromP3(Point q) {
    points[0].fromP3(q);
    final q2 = Point.zero();
    q2.add(q, q);
    final tmpP3 = Point.zero();
    final tmpP1xP1 = projP1xP1.zero();
    for (int i = 0; i < 63; i++) {
      points[i + 1]
          .fromP3(tmpP3..fromP1xP1(tmpP1xP1..addAffine(q2, points[i])));
    }
  }

  /// Given odd x with 0 < x < 2^7, return x*Q (in variable time).
  void selectInto(affineCached dest, int x) {
    dest.copyFrom(points[(x / 2).floor()]);
  }

  @override
  operator ==(Object other) =>
      other is nafLookupTable8 &&
      points.asMap().entries.every((e) {
        final i = e.key;
        final p = e.value;
        return p == other.points[i];
      });

  @override
  int get hashCode => points.map((e) => e.hashCode).reduce((a, b) => a ^ b);
}
