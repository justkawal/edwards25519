part of edwards25519;

bool checkOnCurve(List<Point> points) {
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    final Element XX = Element.feZero()..square(p.x);
    final Element YY = Element.feZero()..square(p.y);
    final Element ZZ = Element.feZero()..square(p.z);
    final Element ZZZZ = Element.feZero()..square(ZZ);
    // -x² + y² = 1 + dx²y²
    // -(X/Z)² + (Y/Z)² = 1 + d(X/Z)²(Y/Z)²
    // (-X² + Y²)/Z² = 1 + (dX²Y²)/Z⁴
    // (-X² + Y²)*Z² = Z⁴ + dX²Y²
    final Element lhs = Element.feZero()..subtract(YY, XX);
    lhs.multiply(lhs, ZZ);
    final Element rhs = Element.feZero()..multiply(Point.d, XX);
    rhs.multiply(rhs, YY);
    rhs.add(rhs, ZZZZ);

    if (lhs.equal(rhs) != 1) {
      throw Exception(
          'Index: $i: X, Y, and Z do not specify a point on the curve\nX = ${p.x}\nY = ${p.y}\nZ = ${p.z}');
    }
    // xy = T/Z
    lhs.multiply(p.x, p.y);
    rhs.multiply(p.z, p.t);
    if (lhs.equal(rhs) != 1) {
      throw Exception(
          'point $i is not valid\nX = ${p.x}\nY = ${p.y}\nZ = ${p.z}');
    }
  }
  return true;
}
