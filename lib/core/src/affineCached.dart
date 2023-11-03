part of edwards25519;

class affineCached {
  late Element YplusX;
  late Element YminusX;
  late Element T2d;

  affineCached.zero() {
    YplusX = Element.feOne();
    YminusX = Element.feOne();
    T2d = Element.feZero();
  }

  void zero() {
    YplusX.set(Element.feOne());
    YminusX.set(Element.feOne());
    T2d.set(Element.feZero());
  }

  void copyFrom(affineCached other) {
    YplusX.set(other.YplusX);
    YminusX.set(other.YminusX);
    T2d.set(other.T2d);
  }

  void fromP3(Point p) {
    YplusX.add(p.y, p.x);
    YminusX.subtract(p.y, p.x);
    T2d.multiply(p.t, Point.d2);

    final Element invZ = Element.feZero();
    invZ.invert(p.z);
    YplusX.multiply(YplusX, invZ);
    YminusX.multiply(YminusX, invZ);
    T2d.multiply(T2d, invZ);
  }

  /// Select sets v to a if cond == 1 and to b if cond == 0.
  void select(affineCached a, affineCached b, int cond) {
    YplusX.select(a.YplusX, b.YplusX, cond);
    YminusX.select(a.YminusX, b.YminusX, cond);
    T2d.select(a.T2d, b.T2d, cond);
  }

  /// CondNeg negates v if cond == 1 and leaves it unchanged if cond == 0.
  void condNeg(int cond) {
    YplusX.swap(YminusX, cond);
    T2d.select(Element.feZero()..negate(T2d), T2d, cond);
  }

  @override
  operator ==(Object other) =>
      other is affineCached &&
      YplusX == other.YplusX &&
      YminusX == other.YminusX &&
      T2d == other.T2d;

  @override
  int get hashCode => YplusX.hashCode ^ YminusX.hashCode ^ T2d.hashCode;
}
