part of edwards25519;

class projP2 {
  Element X;
  Element Y;
  Element Z;

  projP2(this.X, this.Y, this.Z);

  factory projP2.zero() {
    return projP2(
      Element.feZero(),
      Element.feOne(),
      Element.feOne(),
    );
  }

  void zero() {
    X.set(Element.feZero());
    Y.set(Element.feOne());
    Z.set(Element.feOne());
  }

  void fromP1xP1(projP1xP1 p) {
    X.multiply(p.X, p.T);
    Y.multiply(p.Y, p.Z);
    Z.multiply(p.Z, p.T);
  }

  factory projP2.fromP3(Point p) {
    return projP2.zero()..fromP3(p);
  }

  void fromP3(Point p) {
    X.set(p.x);
    Y.set(p.y);
    Z.set(p.z);
  }
}
