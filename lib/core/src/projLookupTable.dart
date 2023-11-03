part of edwards25519;

/// A dynamic lookup table for variable-base, constant-time scalar muls.
class projLookupTable {
  final List<projCached> points = List.generate(8, (_) => projCached.zero());

  /// Builds a lookup table at runtime. Fast.
  void fromP3(Point q) {
    // Goal: v.points[i] = (i+1)*Q, i.e., Q, 2Q, ..., 8Q
    // This allows lookup of -8Q, ..., -Q, 0, Q, ..., 8Q
    points[0].fromP3(q);
    final tmpP3 = Point.zero();
    final tmpP1xP1 = projP1xP1.zero();

    for (int i = 0; i < 7; i++) {
      // Compute (i+1)*Q as Q + i*Q and convert to a ProjCached
      // This is needlessly complicated because the API has explicit
      // receivers instead of creating stack objects and relying on RVO
      points[i + 1].fromP3(tmpP3..fromP1xP1(tmpP1xP1..add(q, points[i])));
    }
  }

  /// Set dest to x*Q, where -8 <= x <= 8, in constant time.
  void selectInto(projCached dest, int x) {
    // Compute xabs = |x|
    final xmask = x >> 7;
    final xabs = (x + xmask) ^ xmask;

    dest.zero();
    for (int j = 1; j <= 8; j++) {
      // Set dest = j*Q if |x| = j
      final cond = constantTimeByteEq(xabs, j);
      dest.select(points[j - 1], dest, cond);
    }
    // Now dest = |x|*Q, conditionally negate to get x*Q
    dest.condNeg(xmask & 1);
  }
}
