part of edwards25519;

/// Point represents a point on the edwards25519 curve.
///
/// This type works similarly to math/big.Int, and all arguments and receivers
/// are allowed to alias.
///
/// The zero value is NOT valid, and it may be used only as a receiver.
class Point {
  /// The point is internally represented in extended coordinates (X, Y, Z, T)
  /// where x = X/Z, y = Y/Z, and xy = T/Z per https://eprint.iacr.org/2008/522.
  Element x;
  Element y;
  Element z;
  Element t;

  Point(this.x, this.y, this.z, this.t);

  /// Sets Point to zero
  factory Point.zero() {
    return Point(
      Element.feZero(),
      Element.feZero(),
      Element.feZero(),
      Element.feZero(),
    );
  }

  /// identity is the point at infinity.
  static final Point identity = Point.newIdentityPoint();

  /// NewIdentityPoint returns a new Point set to the identity.
  factory Point.newIdentityPoint() {
    return Point(
      Element.fromInt(
        2251799813685229,
        2251799813685247,
        2251799813685247,
        2251799813685247,
        2251799813685247,
      ),
      Element.feOne(),
      Element.feOne(),
      Element.fromInt(
        2251799813685229,
        2251799813685247,
        2251799813685247,
        2251799813685247,
        2251799813685247,
      ),
    );
  }

  /// generator is the canonical curve basepoint. See TestGenerator for the
  /// correspondence of this encoding with the values in RFC 8032.
  static final generator = Point.newGeneratorPoint();

  /// NewGeneratorPoint returns a new Point set to the canonical generator.
  factory Point.newGeneratorPoint() {
    return Point(
        Element.fromInt(
          1738742601995546,
          1146398526822698,
          2070867633025821,
          562264141797630,
          587772402128613,
        ),
        Element.fromInt(
          1801439850948184,
          1351079888211148,
          450359962737049,
          900719925474099,
          1801439850948198,
        ),
        Element.feOne(),
        Element.fromInt(
          1841354044333475,
          16398895984059,
          755974180946558,
          900171276175154,
          1821297809914039,
        ));
  }

  /// Set sets v = u, and returns v.
  void set(Point u) {
    x.set(u.x);
    y.set(u.y);
    z.set(u.z);
    t.set(u.t);
  }

  /// Bytes returns the canonical 32-byte encoding of v, according to RFC 8032,
  /// Section 5.1.2.
  List<int> Bytes() {
    // This function is outlined to make the allocations inline in the caller
    // rather than happen on the heap.
    final buf = List<int>.filled(32, 0);
    bytes(buf);
    return buf;
  }

  void bytes(List<int> buf) {
    assert(buf.length == 32);

    Element zInv = Element.feOne();
    Element xx = Element.feOne();
    Element yy = Element.feOne();
    zInv.invert(z); // zInv = 1 / Z
    xx.multiply(x, zInv); // x = X / Z
    yy.multiply(y, zInv); // y = Y / Z

    copyFieldElement(buf, yy);
    buf[31] |= xx.isNegative() << 7;
  }

  /// SetBytes sets v = x, where x is a 32-byte encoding of v. If x does not
  /// represent a valid point on the curve, SetBytes returns nil and an error and
  /// the receiver is unchanged. Otherwise, SetBytes returns v.
  ///
  /// Note that SetBytes accepts all non-canonical encodings of valid points.
  /// That is, it follows decoding rules that match most implementations in
  /// the ecosystem rather than RFC 8032.
  void setBytes(Uint8List bytes) {
    // Specifically, the non-canonical encodings that are accepted are
    //   1) the ones where the field element is not reduced (see the
    //      (Element).setBytes docs) and
    //   2) the ones where the x-coordinate is zero and the sign bit is set.
    //
    // Read more at https://hdevalence.ca/blog/2020-10-04-its-25519am,
    // specifically the "Canonical A, R" section.

    final y1 = Element.feZero()..setBytes(bytes);

    // -x² + y² = 1 + dx²y²
    // x² + dx²y² = x²(dy² + 1) = y² - 1
    // x² = (y² - 1) / (dy² + 1)

    // u = y² - 1
    final y2 = Element.feZero()..square(y1);
    final u = Element.feZero()..subtract(y2, Element.feOne());

    // v = dy² + 1
    final vv = Element.feZero()..multiply(y2, d);
    vv.add(vv, Element.feOne());

    // x = +√(u/v)
    final (Element xx, int wasSquare) = Element.feZero().sqrtRatio(u, vv);
    if (wasSquare == 0) {
      throw Exception("edwards25519: invalid point encoding");
    }

    // Select the negative square root if the sign bit is set.
    final xxNeg = Element.feZero()..negate(xx);
    xx.select(xxNeg, xx, bytes[31] >> 7);

    x.set(xx);
    y.set(y1);
    z.one();
    t.multiply(xx, y1); // xy = T / Z
  }

  void copyFieldElement(List<int> buf, Element v) {
    buf.setAll(0, v.Bytes().toList());
  }

  void fromP1xP1(projP1xP1 p) {
    x.multiply(p.X, p.T);
    y.multiply(p.Y, p.Z);
    z.multiply(p.Z, p.T);
    t.multiply(p.X, p.Y);
  }

  void fromP2(projP2 p) {
    x.multiply(p.X, p.Z);
    y.multiply(p.Y, p.Z);
    z.square(p.Z);
    t.multiply(p.X, p.Y);
  }

  /// d is a constant in the curve equation.
  static final d = Element.feZero()
    ..setBytes(Uint8List.fromList([
      0xa3,
      0x78,
      0x59,
      0x13,
      0xca,
      0x4d,
      0xeb,
      0x75,
      0xab,
      0xd8,
      0x41,
      0x41,
      0x4d,
      0x0a,
      0x70,
      0x00,
      0x98,
      0xe8,
      0x79,
      0x77,
      0x79,
      0x40,
      0xc7,
      0x8c,
      0x73,
      0xfe,
      0x6f,
      0x2b,
      0xee,
      0x6c,
      0x03,
      0x52
    ]));

  static final d2 = Element.feZero()..add(d, d);

  /// (Re)addition and subtraction.
  /// Add sets v = p + q, and returns v.
  void add(Point p, Point q) {
    final qCached = projCached.zero()..fromP3(q);
    final result = projP1xP1.zero()..add(p, qCached);
    fromP1xP1(result);
  }

  /// Subtract sets v = p - q, and returns v.
  void subtract(Point p, Point q) {
    final qCached = projCached.zero()..fromP3(q);
    final result = projP1xP1.zero()..sub(p, qCached);
    fromP1xP1(result);
  }

  /// Negate sets v = -p, and returns v.
  void negate(Point p) {
    x.negate(p.x);
    y.set(p.y);
    z.set(p.z);
    t.negate(p.t);
  }

  /// Equal returns 1 if v is equivalent to u, and 0 otherwise.
  int equal(Point u) {
    final t1 = Element.feZero()..multiply(x, u.z);
    final t2 = Element.feZero()..multiply(u.x, z);
    final t3 = Element.feZero()..multiply(y, u.z);
    final t4 = Element.feZero()..multiply(u.y, z);

    return t1.equal(t2) & t3.equal(t4);
  }

  /// ExtendedCoordinates returns v in extended coordinates (X:Y:Z:T) where
  /// x = X/Z, y = Y/Z, and xy = T/Z as in https://eprint.iacr.org/2008/522.
  (Element X, Element Y, Element Z, Element T) ExtendedCoordinates() {
    // This function is outlined to make the allocations inline in the caller
    // rather than happen on the heap. Don't change the style without making
    // sure it doesn't increase the inliner cost.
    final List<Element> e = List<Element>.generate(4, (_) => Element.feZero());
    return extendedCoordinates(e);
  }

  (Element X, Element Y, Element Z, Element T) extendedCoordinates(
      List<Element> e) {
    e[0].set(x);
    e[1].set(y);
    e[2].set(z);
    e[3].set(t);
    return (e[0], e[1], e[2], e[3]);
  }

  /// SetExtendedCoordinates sets v = (X:Y:Z:T) in extended coordinates where
  /// x = X/Z, y = Y/Z, and xy = T/Z as in https://eprint.iacr.org/2008/522.
  ///
  /// If the coordinates are invalid or don't represent a valid point on the curve,
  /// SetExtendedCoordinates returns nil and an error and the receiver is
  /// unchanged. Otherwise, SetExtendedCoordinates returns v.
  void setExtendedCoordinates(Element X, Element Y, Element Z, Element T) {
    if (!checkOnCurve([Point(X, Y, Z, T)])) {
      throw ArgumentError("edwards25519: invalid point coordinates");
    }
    x.set(X);
    y.set(Y);
    z.set(Z);
    t.set(T);
  }

  /// BytesMontgomery converts v to a point on the birationally-equivalent
  /// Curve25519 Montgomery curve, and returns its canonical 32 bytes encoding
  /// according to RFC 7748.
  ///
  /// Note that BytesMontgomery only encodes the u-coordinate, so v and -v encode
  /// to the same value. If v is the identity point, BytesMontgomery returns 32
  /// zero bytes, analogously to the X25519 function.
  ///
  /// The lack of an inverse operation (such as SetMontgomeryBytes) is deliberate:
  /// while every valid edwards25519 point has a unique u-coordinate Montgomery
  /// encoding, X25519 accepts inputs on the quadratic twist, which don't correspond
  /// to any edwards25519 point, and every other X25519 input corresponds to two
  /// edwards25519 points.
  List<int> BytesMontgomery() {
    // This function is outlined to make the allocations inline in the caller
    // rather than happen on the heap.
    //var buf [32]byte
    final buf = List<int>.filled(32, 0);
    bytesMontgomery(buf);
    return buf;
  }

  void bytesMontgomery(List<int> buf) {
    // RFC 7748, Section 4.1 provides the bilinear map to calculate the
    // Montgomery u-coordinate
    //
    //              u = (1 + y) / (1 - y)
    //
    // where y = Y / Z.

    final y1 = Element.feZero();
    final recip = Element.feZero();
    final u = Element.feZero();

    y1.multiply(y, y1..invert(z)); // y = Y / Z
    recip.invert(recip..subtract(Element.feOne(), y1)); // r = 1/(1 - y)
    u.multiply(u..add(Element.feOne(), y1), recip); // u = (1 + y)*r

    copyFieldElement(buf, u);
  }

  /// MultByCofactor sets v = 8 * p, and returns v.
  void multByCofactor(Point p) {
    final result = projP1xP1.zero();
    final pp = projP2.fromP3(p);
    result.double(pp);
    pp.fromP1xP1(result);
    result.double(pp);
    pp.fromP1xP1(result);
    result.double(pp);
    fromP1xP1(result);
  }

  // MultiScalarMult sets v = sum(scalars[i] * points[i]), and returns v.
  //
  // Execution time depends only on the lengths of the two slices, which must match.
  void multiScalarMult(List<Scalar> scalars, List<Point> points) {
    if (scalars.length != points.length) {
      throw Exception(
          "edwards25519: called MultiScalarMult with different size inputs");
    }
    // Proceed as in the single-base case, but share doublings
    // between each point in the multiscalar equation.

    // Build lookup tables for each point
    final tables =
        List<projLookupTable>.generate(points.length, (_) => projLookupTable());
    for (int i = 0; i < tables.length; i++) {
      tables[i].fromP3(points[i]);
    }
    // Compute signed radix-16 digits for each scalar
    final digits = List<List<int>>.generate(
        scalars.length, (_) => List<int>.filled(64, 0));
    for (int i = 0; i < digits.length; i++) {
      digits[i] = scalars[i].signedRadix16();
    }

    // Unwrap first loop iteration to save computing 16*identity
    final multiple = projCached.zero();
    final tmp1 = projP1xP1.zero();
    final tmp2 = projP2.zero();
    // Lookup-and-add the appropriate multiple of each input point
    for (int j = 0; j < tables.length; j++) {
      tables[j].selectInto(multiple, digits[j][63]);
      tmp1.add(this, multiple); // tmp1 = v + x_(j,63)*Q in P1xP1 coords
      fromP1xP1(tmp1); // update v
    }
    tmp2.fromP3(this); // set up tmp2 = v in P2 coords for next iteration
    for (int i = 62; i >= 0; i--) {
      tmp1.double(tmp2); // tmp1 =  2*(prev) in P1xP1 coords
      tmp2.fromP1xP1(tmp1); // tmp2 =  2*(prev) in P2 coords
      tmp1.double(tmp2); // tmp1 =  4*(prev) in P1xP1 coords
      tmp2.fromP1xP1(tmp1); // tmp2 =  4*(prev) in P2 coords
      tmp1.double(tmp2); // tmp1 =  8*(prev) in P1xP1 coords
      tmp2.fromP1xP1(tmp1); // tmp2 =  8*(prev) in P2 coords
      tmp1.double(tmp2); // tmp1 = 16*(prev) in P1xP1 coords
      fromP1xP1(tmp1); //    v = 16*(prev) in P3 coords
      // Lookup-and-add the appropriate multiple of each input point
      for (int j = 0; j < tables.length; j++) {
        tables[j].selectInto(multiple, digits[j][i]);
        tmp1.add(this, multiple); // tmp1 = v + x_(j,i)*Q in P1xP1 coords
        fromP1xP1(tmp1); // update v
      }
      tmp2.fromP3(this); // set up tmp2 = v in P2 coords for next iteration
    }
  }

  // VarTimeMultiScalarMult sets v = sum(scalars[i] * points[i]), and returns v.
  //
  // Execution time depends on the inputs.
  void varTimeMultiScalarMult(List<Scalar> scalars, List<Point> points) {
    if (scalars.length != points.length) {
      throw Exception(
          "edwards25519: called VarTimeMultiScalarMult with different size inputs");
    }

    // Generalize double-base NAF computation to arbitrary sizes.
    // Here all the points are dynamic, so we only use the smaller
    // tables.

    // Build lookup tables for each point
    final tables =
        List<nafLookupTable5>.generate(points.length, (_) => nafLookupTable5());
    for (int i = 0; i < tables.length; i++) {
      tables[i].fromP3(points[i]);
    }
    // Compute a NAF for each scalar
    final nafs = List<List<int>>.generate(
        scalars.length, (_) => List<int>.filled(256, 0));
    for (int i = 0; i < nafs.length; i++) {
      nafs[i] = scalars[i].nonAdjacentForm(5);
    }

    final multiple = projCached.zero();
    final tmp1 = projP1xP1.zero();
    final tmp2 = projP2.zero();
    tmp2.zero();

    // Move from high to low bits, doubling the accumulator
    // at each iteration and checking whether there is a nonzero
    // coefficient to look up a multiple of.
    //
    // Skip trying to find the first nonzero coefficent, because
    // searching might be more work than a few extra doublings.
    for (int i = 255; i >= 0; i--) {
      tmp1.double(tmp2);

      for (int j = 0; j < nafs.length; j++) {
        if (nafs[j][i] > 0) {
          fromP1xP1(tmp1);
          tables[j].selectInto(multiple, nafs[j][i]);
          tmp1.add(this, multiple);
        } else if (nafs[j][i] < 0) {
          fromP1xP1(tmp1);
          tables[j].selectInto(multiple, -nafs[j][i]);
          tmp1.sub(this, multiple);
        }
      }
      tmp2.fromP1xP1(tmp1);
    }

    fromP2(tmp2);
  }

  /// ScalarBaseMult sets v = x * B, where B is the canonical generator, and
  /// returns v.
  ///
  /// The scalar multiplication is done in constant time.
  void scalarBaseMult(Scalar x) {
    final basepointTable = basepointTablePrecomp.instance.table;

    // Write x = sum(x_i * 16^i) so  x*B = sum( B*x_i*16^i )
    // as described in the Ed25519 paper
    //
    // Group even and odd coefficients
    // x*B     = x_0*16^0*B + x_2*16^2*B + ... + x_62*16^62*B
    //         + x_1*16^1*B + x_3*16^3*B + ... + x_63*16^63*B
    // x*B     = x_0*16^0*B + x_2*16^2*B + ... + x_62*16^62*B
    //    + 16*( x_1*16^0*B + x_3*16^2*B + ... + x_63*16^62*B)
    //
    // We use a lookup table for each i to get x_i*16^(2*i)*B
    // and do four doublings to multiply by 16.
    final digits = x.signedRadix16();

    final multiple = affineCached.zero();
    final tmp1 = projP1xP1.zero();
    final tmp2 = projP2.zero();

    // Accumulate the odd components first
    set(Point.newIdentityPoint());
    for (int i = 1; i < 64; i += 2) {
      basepointTable[(i / 2).floor()].selectInto(multiple, digits[i]);
      tmp1.addAffine(this, multiple);
      fromP1xP1(tmp1);
    }

    // Multiply by 16
    tmp2.fromP3(this); // tmp2 =    v in P2 coords
    tmp1.double(tmp2); // tmp1 =  2*v in P1xP1 coords
    tmp2.fromP1xP1(tmp1); // tmp2 =  2*v in P2 coords
    tmp1.double(tmp2); // tmp1 =  4*v in P1xP1 coords
    tmp2.fromP1xP1(tmp1); // tmp2 =  4*v in P2 coords
    tmp1.double(tmp2); // tmp1 =  8*v in P1xP1 coords
    tmp2.fromP1xP1(tmp1); // tmp2 =  8*v in P2 coords
    tmp1.double(tmp2); // tmp1 = 16*v in P1xP1 coords
    fromP1xP1(tmp1); // now v = 16*(odd components)

    // Accumulate the even components
    for (int i = 0; i < 64; i += 2) {
      basepointTable[(i / 2).floor()].selectInto(multiple, digits[i]);
      tmp1.addAffine(this, multiple);
      fromP1xP1(tmp1);
    }
  }

  /// ScalarMult sets v = x * q, and returns v.
  ///
  /// The scalar multiplication is done in constant time.
  void scalarMult(Scalar x, Point q) {
    final projLookupTable table = projLookupTable();
    table.fromP3(q);

    // Write x = sum(x_i * 16^i)
    // so  x*Q = sum( Q*x_i*16^i )
    //         = Q*x_0 + 16*(Q*x_1 + 16*( ... + Q*x_63) ... )
    //           <------compute inside out---------
    //
    // We use the lookup table to get the x_i*Q values
    // and do four doublings to compute 16*Q
    final digits = x.signedRadix16();

    // Unwrap first loop iteration to save computing 16*identity
    final multiple = projCached.zero();
    final tmp1 = projP1xP1.zero();
    final tmp2 = projP2.zero();
    table.selectInto(multiple, digits[63]);

    set(Point.newIdentityPoint());
    tmp1.add(this, multiple); // tmp1 = x_63*Q in P1xP1 coords
    for (int i = 62; i >= 0; i--) {
      tmp2.fromP1xP1(tmp1); // tmp2 =    (prev) in P2 coords
      tmp1.double(tmp2); // tmp1 =  2*(prev) in P1xP1 coords
      tmp2.fromP1xP1(tmp1); // tmp2 =  2*(prev) in P2 coords
      tmp1.double(tmp2); // tmp1 =  4*(prev) in P1xP1 coords
      tmp2.fromP1xP1(tmp1); // tmp2 =  4*(prev) in P2 coords
      tmp1.double(tmp2); // tmp1 =  8*(prev) in P1xP1 coords
      tmp2.fromP1xP1(tmp1); // tmp2 =  8*(prev) in P2 coords
      tmp1.double(tmp2); // tmp1 = 16*(prev) in P1xP1 coords
      fromP1xP1(tmp1); //    v = 16*(prev) in P3 coords
      table.selectInto(multiple, digits[i]);
      tmp1.add(this, multiple); // tmp1 = x_i*Q + 16*(prev) in P1xP1 coords
    }
    fromP1xP1(tmp1);
  }

  /// VarTimeDoubleScalarBaseMult sets v = a * A + b * B, where B is the canonical
  /// generator, and returns v.
  ///
  /// Execution time depends on the inputs.
  void varTimeDoubleScalarBaseMult(Scalar a, Point A, Scalar b) {
    // Similarly to the single variable-base approach, we compute
    // digits and use them with a lookup table.  However, because
    // we are allowed to do variable-time operations, we don't
    // need constant-time lookups or constant-time digit
    // computations.
    //
    // So we use a non-adjacent form of some width w instead of
    // radix 16.  This is like a binary representation (one digit
    // for each binary place) but we allow the digits to grow in
    // magnitude up to 2^{w-1} so that the nonzero digits are as
    // sparse as possible.  Intuitively, this "condenses" the
    // "mass" of the scalar onto sparse coefficients (meaning
    // fewer additions).

    final basepointNafTable = basepointNafTablePrecomp.instance.table;
    final nafLookupTable5 aTable = nafLookupTable5()..fromP3(A);
    // Because the basepoint is fixed, we can use a wider NAF
    // corresponding to a bigger table.
    final aNaf = a.nonAdjacentForm(5);
    final bNaf = b.nonAdjacentForm(8);

    // Find the first nonzero coefficient.

    for (int j = 255; j >= 0; j--) {
      if (aNaf[j] != 0 || bNaf[j] != 0) {
        break;
      }
    }

    final multA = projCached.zero();
    final multB = affineCached.zero();
    final tmp1 = projP1xP1.zero();
    final tmp2 = projP2.zero();
    tmp2.zero();

    // Move from high to low bits, doubling the accumulator
    // at each iteration and checking whether there is a nonzero
    // coefficient to look up a multiple of.
    for (int i = 255; i >= 0; i--) {
      tmp1.double(tmp2);

      // Only update v if we have a nonzero coeff to add in.
      if (aNaf[i] > 0) {
        fromP1xP1(tmp1);
        aTable.selectInto(multA, aNaf[i]);
        tmp1.add(this, multA);
      } else if (aNaf[i] < 0) {
        fromP1xP1(tmp1);
        aTable.selectInto(multA, -aNaf[i]);
        tmp1.sub(this, multA);
      }

      if (bNaf[i] > 0) {
        fromP1xP1(tmp1);
        basepointNafTable.selectInto(multB, bNaf[i]);
        tmp1.addAffine(this, multB);
      } else if (bNaf[i] < 0) {
        fromP1xP1(tmp1);
        basepointNafTable.selectInto(multB, -bNaf[i]);
        tmp1.subAffine(this, multB);
      }

      tmp2.fromP1xP1(tmp1);
    }

    fromP2(tmp2);
  }

  /// Make the type not comparable (i.e. used with == or as a map key), as
  /// equivalent points can be represented by different values.
  @override
  bool operator ==(Object other) => false;

  /// ignore:
  @override
  int get hashCode => super.hashCode;
}
