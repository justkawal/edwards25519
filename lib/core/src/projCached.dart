part of edwards25519;

class projCached {
  late Element YplusX;
  late Element YminusX;
  late Element Z;
  late Element T2d;

  projCached(this.YplusX, this.YminusX, this.Z, this.T2d);

  factory projCached.zero() {
    return projCached(
      Element.feOne(),
      Element.feOne(),
      Element.feOne(),
      Element.feZero(),
    );
  }

  void zero() {
    YplusX.set(Element.feOne());
    YminusX.set(Element.feOne());
    Z.set(Element.feOne());
    T2d.set(Element.feZero());
  }

  void copyFrom(projCached other) {
    YplusX.set(other.YplusX);
    YminusX.set(other.YminusX);
    Z.set(other.Z);
    T2d.set(other.T2d);
  }

  void fromP3(Point p) {
    YplusX.add(p.y, p.x);
    YminusX.subtract(p.y, p.x);
    Z.set(p.z);
    T2d.multiply(p.t, Point.d2);
  }

  /// Select sets v to a if cond == 1 and to b if cond == 0.
  void select(projCached a, projCached b, int cond) {
    YplusX.select(a.YplusX, b.YplusX, cond);
    YminusX.select(a.YminusX, b.YminusX, cond);
    Z.select(a.Z, b.Z, cond);
    T2d.select(a.T2d, b.T2d, cond);
  }

  /// CondNeg negates v if cond == 1 and leaves it unchanged if cond == 0.
  void condNeg(int cond) {
    YplusX.swap(YminusX, cond);
    T2d.select(Element.feZero()..negate(T2d), T2d, cond);
  }

  @override
  operator ==(Object other) =>
      other is projCached &&
      YplusX == other.YplusX &&
      YminusX == other.YminusX &&
      Z == other.Z &&
      T2d == other.T2d;

  @override
  int get hashCode =>
      YplusX.hashCode ^ YminusX.hashCode ^ Z.hashCode ^ T2d.hashCode;
}
