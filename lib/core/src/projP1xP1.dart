part of edwards25519;

class projP1xP1 {
  Element X;
  Element Y;
  Element Z;
  Element T;

  projP1xP1(this.X, this.Y, this.Z, this.T);

  factory projP1xP1.zero() {
    return projP1xP1(
      Element.feZero(),
      Element.feZero(),
      Element.feZero(),
      Element.feZero(),
    );
  }

  void add(Point p, projCached q) {
    final Element YplusX = Element.feZero();
    final Element YminusX = Element.feZero();
    final Element PP = Element.feZero();
    final Element MM = Element.feZero();
    final Element TT2d = Element.feZero();
    final Element ZZ2 = Element.feZero();

    YplusX.add(p.y, p.x);
    YminusX.subtract(p.y, p.x);

    PP.multiply(YplusX, q.YplusX);
    MM.multiply(YminusX, q.YminusX);
    TT2d.multiply(p.t, q.T2d);
    ZZ2.multiply(p.z, q.Z);

    ZZ2.add(ZZ2, ZZ2);

    X.subtract(PP, MM);
    Y.add(PP, MM);
    Z.add(ZZ2, TT2d);
    T.subtract(ZZ2, TT2d);
  }

  void sub(Point p, projCached q) {
    final Element YplusX = Element.feZero();
    final Element YminusX = Element.feZero();
    final Element PP = Element.feZero();
    final Element MM = Element.feZero();
    final Element TT2d = Element.feZero();
    final Element ZZ2 = Element.feZero();

    YplusX.add(p.y, p.x);
    YminusX.subtract(p.y, p.x);

    PP.multiply(YplusX, q.YminusX); // flipped sign
    MM.multiply(YminusX, q.YplusX); // flipped sign
    TT2d.multiply(p.t, q.T2d);
    ZZ2.multiply(p.z, q.Z);

    ZZ2.add(ZZ2, ZZ2);

    X.subtract(PP, MM);
    Y.add(PP, MM);
    Z.subtract(ZZ2, TT2d); // flipped sign
    T.add(ZZ2, TT2d); // flipped sign
  }

  void addAffine(Point p, affineCached q) {
    final Element YplusX = Element.feZero();
    final Element YminusX = Element.feZero();
    final Element PP = Element.feZero();
    final Element MM = Element.feZero();
    final Element TT2d = Element.feZero();
    final Element Z2 = Element.feZero();

    YplusX.add(p.y, p.x);
    YminusX.subtract(p.y, p.x);

    PP.multiply(YplusX, q.YplusX);
    MM.multiply(YminusX, q.YminusX);
    TT2d.multiply(p.t, q.T2d);

    Z2.add(p.z, p.z);

    X.subtract(PP, MM);
    Y.add(PP, MM);
    Z.add(Z2, TT2d);
    T.subtract(Z2, TT2d);
  }

  void subAffine(Point p, affineCached q) {
    final Element YplusX = Element.feZero();
    final Element YminusX = Element.feZero();
    final Element PP = Element.feZero();
    final Element MM = Element.feZero();
    final Element TT2d = Element.feZero();
    final Element Z2 = Element.feZero();

    YplusX.add(p.y, p.x);
    YminusX.subtract(p.y, p.x);

    PP.multiply(YplusX, q.YminusX); // flipped sign
    MM.multiply(YminusX, q.YplusX); // flipped sign
    TT2d.multiply(p.t, q.T2d);

    Z2.add(p.z, p.z);

    X.subtract(PP, MM);
    Y.add(PP, MM);
    Z.subtract(Z2, TT2d); // flipped sign
    T.add(Z2, TT2d); // flipped sign
  }

  void double(projP2 p) {
    final Element XX = Element.feZero();
    final Element YY = Element.feZero();
    final Element ZZ2 = Element.feZero();
    final Element XplusYsq = Element.feZero();

    XX.square(p.X);
    YY.square(p.Y);

    ZZ2.square(p.Z);
    ZZ2.add(ZZ2, ZZ2);

    XplusYsq.add(p.X, p.Y);
    XplusYsq.square(XplusYsq);

    Y.add(YY, XX);
    Z.subtract(YY, XX);
    X.subtract(XplusYsq, Y);
    T.subtract(ZZ2, Z);
  }
}
