part of edwards25519;

/// A dynamic lookup table for variable-base, constant-time scalar muls.
class nafLookupTable5 {
  final List<projCached> points = List.generate(8, (_) => projCached.zero());

  /// Builds a lookup table at runtime. Fast.
  void fromP3(Point q) {
    // Goal: v.points[i] = (2*i+1)*Q, i.e., Q, 3Q, 5Q, ..., 15Q
    // This allows lookup of -15Q, ..., -3Q, -Q, 0, Q, 3Q, ..., 15Q
    points[0].fromP3(q);
    final q2 = Point.zero()..add(q, q);
    final tmpP3 = Point.zero();
    final tmpP1xP1 = projP1xP1.zero();
    for (int i = 0; i < 7; i++) {
      points[i + 1].fromP3(tmpP3..fromP1xP1(tmpP1xP1..add(q2, points[i])));
    }
  }

  /// Given odd x with 0 < x < 2^4, return x*Q (in variable time).
  void selectInto(projCached dest, int x) {
    dest.copyFrom(points[(x / 2).floor()]);
  }

  @override
  operator ==(Object other) =>
      other is nafLookupTable5 &&
      points.asMap().entries.every((e) {
        final i = e.key;
        final p = e.value;
        return p == other.points[i];
      });

  @override
  int get hashCode => points.map((e) => e.hashCode).reduce((a, b) => a ^ b);
}
