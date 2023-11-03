part of edwards25519;

/// Element represents an element of the field GF(2^255-19). Note that this
/// is not a cryptographically secure group, and should only be used to interact
/// with edwards25519.Point coordinates.
///
/// This type works similarly to math/big.Int, and all arguments and receivers
/// are allowed to alias.
///
/// The zero value is a valid zero element.

final maskLow51Bits = (BigInt.one << 51) - BigInt.one;
final bigInt19 = BigInt.from(19);

final _fFFFFFFFFFFDA = BigInt.parse('FFFFFFFFFFFDA', radix: 16);
final _fFFFFFFFFFFFE = BigInt.parse('FFFFFFFFFFFFE', radix: 16);

class Element {
  /// An element t represents the integer
  ///     t.l0 + t.l1*2^51 + t.l2*2^102 + t.l3*2^153 + t.l4*2^204
  ///
  /// Between operations, all limbs are expected to be lower than 2^52.
  late BigInt l0;
  late BigInt l1;
  late BigInt l2;
  late BigInt l3;
  late BigInt l4;

  Element(this.l0, this.l1, this.l2, this.l3, this.l4);

  factory Element.fromInt(int l0, int l1, int l2, int l3, int l4) =>
      Element(l0.toBigInt, l1.toBigInt, l2.toBigInt, l3.toBigInt, l4.toBigInt);

  factory Element.feZero() => Element._()..zero();

  factory Element.feOne() => Element._()..one();

  Element._();

  /// Zero sets v = 0, and returns v.
  void zero() {
    l0 = BigInt.zero;
    l1 = BigInt.zero;
    l2 = BigInt.zero;
    l3 = BigInt.zero;
    l4 = BigInt.zero;
  }

  /// One sets v = 1, and returns v.
  void one() {
    l0 = BigInt.one;
    l1 = BigInt.zero;
    l2 = BigInt.zero;
    l3 = BigInt.zero;
    l4 = BigInt.zero;
  }

  /// reduce reduces v modulo 2^255 - 19 and returns it.
  void reduce() {
    carryPropagateGeneric();

    // After the light reduction we now have a field element representation
    // v < 2^255 + 2^13 * 19, but need v < 2^255 - 19.

    // If v >= 2^255 - 19, then v + 19 >= 2^255, which would overflow 2^255 - 1,
    // generating a carry. That is, c will be 0 if v < 2^255 - 19, and 1 otherwise.
    var c = (l0 + bigInt19) >> 51;
    c = (l1 + c) >> 51;
    c = (l2 + c) >> 51;
    c = (l3 + c) >> 51;
    c = (l4 + c) >> 51;

    // If v < 2^255 - 19 and c = 0, this will be a no-op. Otherwise, it's
    // effectively applying the reduction identity to the carry.
    l0 += bigInt19 * c;

    l1 += l0 >> 51;
    l0 &= maskLow51Bits;
    l2 += l1 >> 51;
    l1 &= maskLow51Bits;
    l3 += l2 >> 51;
    l2 &= maskLow51Bits;
    l4 += l3 >> 51;
    l3 &= maskLow51Bits;
    // no additional carry
    l4 &= maskLow51Bits;
  }

  /// Add sets v = a + b, and returns v.
  void add(Element a, Element b) {
    l0 = a.l0 + b.l0;
    l1 = a.l1 + b.l1;
    l2 = a.l2 + b.l2;
    l3 = a.l3 + b.l3;
    l4 = a.l4 + b.l4;
    // Using the generic implementation here is actually faster than the
    // assembly. Probably because the body of this function is so simple that
    // the compiler can figure out better optimizations by inlining the carry
    // propagation.
    carryPropagateGeneric();
  }

  /// Subtract sets v = a - b, and returns v.
  void subtract(Element a, Element b) {
    // We first add 2 * p, to guarantee the subtraction won't underflow, and
    // then subtract b (which can be up to 2^255 + 2^13 * 19).
    l0 = (a.l0 + _fFFFFFFFFFFDA) - b.l0;
    l1 = (a.l1 + _fFFFFFFFFFFFE) - b.l1;
    l2 = (a.l2 + _fFFFFFFFFFFFE) - b.l2;
    l3 = (a.l3 + _fFFFFFFFFFFFE) - b.l3;
    l4 = (a.l4 + _fFFFFFFFFFFFE) - b.l4;
    carryPropagateGeneric();
  }

  /// Negate sets v = -a, and returns v.
  void negate(Element a) {
    subtract(Element.feZero(), a);
  }

  /// Invert sets v = 1/z mod p, and returns v.
  ///
  /// If z == 0, Invert returns v = 0.
  void invert(Element z) {
    // Inversion is implemented as exponentiation with exponent p − 2. It uses the
    // same sequence of 255 squarings and 11 multiplications as [Curve25519].
    Element z2 = Element.feZero();
    Element z9 = Element.feZero();
    Element z11 = Element.feZero();
    Element z2_5_0 = Element.feZero();
    Element z2_10_0 = Element.feZero();
    Element z2_20_0 = Element.feZero();
    Element z2_50_0 = Element.feZero();
    Element z2_100_0 = Element.feZero();
    Element t = Element.feZero();

    z2.square(z); // 2
    t.square(z2); // 4
    t.square(t); // 8
    z9.multiply(t, z); // 9
    z11.multiply(z9, z2); // 11
    t.square(z11); // 22
    z2_5_0.multiply(t, z9); // 31 = 2^5 - 2^0

    t.square(z2_5_0); // 2^6 - 2^1
    for (var i = 0; i < 4; i++) {
      t.square(t); // 2^10 - 2^5
    }
    z2_10_0.multiply(t, z2_5_0); // 2^10 - 2^0

    t.square(z2_10_0); // 2^11 - 2^1
    for (var i = 0; i < 9; i++) {
      t.square(t); // 2^20 - 2^10
    }
    z2_20_0.multiply(t, z2_10_0); // 2^20 - 2^0

    t.square(z2_20_0); // 2^21 - 2^1
    for (var i = 0; i < 19; i++) {
      t.square(t); // 2^40 - 2^20
    }
    t.multiply(t, z2_20_0); // 2^40 - 2^0

    t.square(t); // 2^41 - 2^1
    for (var i = 0; i < 9; i++) {
      t.square(t); // 2^50 - 2^10
    }
    z2_50_0.multiply(t, z2_10_0); // 2^50 - 2^0

    t.square(z2_50_0); // 2^51 - 2^1
    for (var i = 0; i < 49; i++) {
      t.square(t); // 2^100 - 2^50
    }
    z2_100_0.multiply(t, z2_50_0); // 2^100 - 2^0

    t.square(z2_100_0); // 2^101 - 2^1
    for (var i = 0; i < 99; i++) {
      t.square(t); // 2^200 - 2^100
    }
    t.multiply(t, z2_100_0); // 2^200 - 2^0

    t.square(t); // 2^201 - 2^1
    for (var i = 0; i < 49; i++) {
      t.square(t); // 2^250 - 2^50
    }
    t.multiply(t, z2_50_0); // 2^250 - 2^0

    t.square(t); // 2^251 - 2^1
    t.square(t); // 2^252 - 2^2
    t.square(t); // 2^253 - 2^3
    t.square(t); // 2^254 - 2^4
    t.square(t); // 2^255 - 2^5

    multiply(t, z11); // 2^255 - 21
  }

  /// Set sets v = a, and returns v.
  void set(Element a) {
    this
      ..l0 = a.l0
      ..l1 = a.l1
      ..l2 = a.l2
      ..l3 = a.l3
      ..l4 = a.l4;
  }

  /// SetBytes sets v to x, where x is a 32-byte little-endian encoding. If x is
  /// not of the right length, SetBytes returns nil and an error, and the
  /// receiver is unchanged.
  ///
  /// Consistent with RFC 7748, the most significant bit (the high bit of the
  /// last byte) is ignored, and non-canonical values (2^255-19 through 2^255-1)
  /// are accepted. Note that this is laxer than specified by RFC 8032, but
  /// consistent with most Ed25519 implementations.
  void setBytes(Uint8List x) {
    if (x.length != 32) {
      throw ArgumentError("edwards25519: invalid field element input size");
    }

    // Bits 0:51 (bytes 0:8, bits 0:64, shift 0, mask 51).
    l0 = ByteData.sublistView(x, 0, 8).getUint64(0, Endian.little).toBigInt;
    l0 &= maskLow51Bits;

    // Bits 51:102 (bytes 6:14, bits 48:112, shift 3, mask 51).
    l1 = ByteData.sublistView(x, 6, 14).getUint64(0, Endian.little).toBigInt >>
        3;
    l1 &= maskLow51Bits;

    // Bits 102:153 (bytes 12:20, bits 96:160, shift 6, mask 51).
    l2 = ByteData.sublistView(x, 12, 20).getUint64(0, Endian.little).toBigInt >>
        6;
    l2 &= maskLow51Bits;

    // Bits 153:204 (bytes 19:27, bits 152:216, shift 1, mask 51).
    l3 = ByteData.sublistView(x, 19, 27).getUint64(0, Endian.little).toBigInt >>
        1;
    l3 &= maskLow51Bits;

    // Bits 204:255 (bytes 24:32, bits 192:256, shift 12, mask 51).
    // Note: not bytes 25:33, shift 4, to avoid overread.
    l4 = ByteData.sublistView(x, 24, 32).getUint64(0, Endian.little).toBigInt >>
        12;
    l4 &= maskLow51Bits;
  }

  /// Bytes returns the canonical 32-byte little-endian encoding of v.
  // ignore: non_constant_identifier_names
  List<int> Bytes() {
    // This function is outlined to create a Uint8List inline in the caller
    // rather than allocate on the heap.
    final List<int> out = List<int>.filled(32, 0);
    _bytes(out);
    return out;
  }

  void _bytes(List<int> out) {
    final Element t = Element(l0, l1, l2, l3, l4)..reduce();

    final list = [t.l0, t.l1, t.l2, t.l3, t.l4];

    final List<int> buf = List<int>.filled(8, 0);
    for (int i = 0; i < 5; i++) {
      int bitsOffset = i * 51;
      for (int j = 0; j < 8; j++) {
        buf[j] =
            ((list[i] << (bitsOffset % 8)) >> (j * 8)).toUnsigned(8).toInt();
      }
      for (int k = 0; k < 8; k++) {
        int off = bitsOffset ~/ 8 + k;
        if (off >= out.length) {
          break;
        }
        out[off] |= buf[k];
      }
    }
  }

  /// Equal returns 1 if v and u are equal, and 0 otherwise.
  int equal(Element u) {
    final (sa, sv) = (u.Bytes(), Bytes());
    return constantTimeCompare(sa, sv);
  }

  /// mask64Bits returns 0xffffffff if cond is 1, and 0 otherwise.
  BigInt mask64Bits(int cond) {
    return ~(BigInt.from(cond) - BigInt.one);
  }

  /// Select sets v to a if cond == 1, and to b if cond == 0.
  void select(Element a, Element b, int cond) {
    final BigInt m = mask64Bits(cond);
    l0 = (m & a.l0) | (~m & b.l0);
    l1 = (m & a.l1) | (~m & b.l1);
    l2 = (m & a.l2) | (~m & b.l2);
    l3 = (m & a.l3) | (~m & b.l3);
    l4 = (m & a.l4) | (~m & b.l4);
  }

  /// Swap swaps v and u if cond == 1 or leaves them unchanged if cond == 0, and returns v.
  void swap(Element u, int cond) {
    final BigInt m = mask64Bits(cond);
    BigInt t = m & (l0 ^ u.l0);
    l0 ^= t;
    u.l0 ^= t;
    t = m & (l1 ^ u.l1);
    l1 ^= t;
    u.l1 ^= t;
    t = m & (l2 ^ u.l2);
    l2 ^= t;
    u.l2 ^= t;
    t = m & (l3 ^ u.l3);
    l3 ^= t;
    u.l3 ^= t;
    t = m & (l4 ^ u.l4);
    l4 ^= t;
    u.l4 ^= t;
  }

  /// IsNegative returns 1 if v is negative, and 0 otherwise.
  int isNegative() {
    return Bytes()[0] & 1;
  }

  /// Absolute sets v to |u|, and returns v.
  void absolute(Element u) {
    select(Element.feZero()..negate(u), u, u.isNegative());
  }

  /// Multiply sets v = x * y, and returns v.
  void multiply(Element x, Element y) {
    feMulGeneric(x, y);
  }

  /// Square sets v = x * x, and returns v.
  void square(Element x) {
    feSquareGeneric(x);
  }

  /// Mult32 sets v = x * y, and returns v.
  void mult32(Element x, int y) {
    final (x0lo, x0hi) = mul51(x.l0, y);
    final (x1lo, x1hi) = mul51(x.l1, y);
    final (x2lo, x2hi) = mul51(x.l2, y);
    final (x3lo, x3hi) = mul51(x.l3, y);
    final (x4lo, x4hi) = mul51(x.l4, y);
    l0 = x0lo + bigInt19 * x4hi; // carried over per the reduction identity
    l1 = x1lo + x0hi;
    l2 = x2lo + x1hi;
    l3 = x3lo + x2hi;
    l4 = x4lo + x3hi;
    // The hi portions are going to be only 32 bits, plus any previous excess,
    // so we can skip the carry propagation.
  }

  /// mul51 returns lo + hi * 2⁵¹ = a * b.
  (BigInt low, BigInt high) mul51(BigInt a, int b) {
    final mh = (a * b.toBigInt) >> 64;
    final ml = a * b.toBigInt;
    final lo = ml & maskLow51Bits;
    final hi = (mh << 13) | (ml >> 51);
    return (lo, hi);
  }

  /// Pow22523 set v = x^((p-5)/8), and returns v. (p-5)/8 is 2^252-3.
  void pow22523(Element x) {
    Element t0 = Element.feZero();
    Element t1 = Element.feZero();
    Element t2 = Element.feZero();

    t0.square(x); // x^2
    t1.square(t0); // x^4
    t1.square(t1); // x^8
    t1.multiply(x, t1); // x^9
    t0.multiply(t0, t1); // x^11
    t0.square(t0); // x^22
    t0.multiply(t1, t0); // x^31
    t1.square(t0); // x^62
    for (var i = 1; i < 5; i++) {
      // x^992
      t1.square(t1);
    }
    t0.multiply(t1, t0); // x^1023 -> 1023 = 2^10 - 1
    t1.square(t0); // 2^11 - 2
    for (var i = 1; i < 10; i++) {
      // 2^20 - 2^10
      t1.square(t1);
    }
    t1.multiply(t1, t0); // 2^20 - 1
    t2.square(t1); // 2^21 - 2
    for (var i = 1; i < 20; i++) {
      // 2^40 - 2^20
      t2.square(t2);
    }
    t1.multiply(t2, t1); // 2^40 - 1
    t1.square(t1); // 2^41 - 2
    for (var i = 1; i < 10; i++) {
      // 2^50 - 2^10
      t1.square(t1);
    }
    t0.multiply(t1, t0); // 2^50 - 1
    t1.square(t0); // 2^51 - 2
    for (var i = 1; i < 50; i++) {
      // 2^100 - 2^50
      t1.square(t1);
    }
    t1.multiply(t1, t0); // 2^100 - 1
    t2.square(t1); // 2^101 - 2
    for (var i = 1; i < 100; i++) {
      // 2^200 - 2^100
      t2.square(t2);
    }
    t1.multiply(t2, t1); // 2^200 - 1
    t1.square(t1); // 2^201 - 2
    for (var i = 1; i < 50; i++) {
      // 2^250 - 2^50
      t1.square(t1);
    }
    t0.multiply(t1, t0); // 2^250 - 1
    t0.square(t0); // 2^251 - 2
    t0.square(t0); // 2^252 - 4
    multiply(t0, x); // 2^252 - 3 -> x^(2^252-3)
  }

  /// sqrtM1 is 2^((p-1)/4), which squared is equal to -1 by Euler's Criterion.
  factory Element.sqrtM1() => Element(
      1718705420411056.toBigInt,
      234908883556509.toBigInt,
      2233514472574048.toBigInt,
      2117202627021982.toBigInt,
      765476049583133.toBigInt);

  /// SqrtRatio sets r to the non-negative square root of the ratio of u and v.
  ///
  /// If u/v is square, SqrtRatio returns r and 1. If u/v is not square, SqrtRatio
  /// sets r according to Section 4.3 of draft-irtf-cfrg-ristretto255-decaf448-00,
  /// and returns r and 0.
  (Element R, int wasSquare) sqrtRatio(
      Element u, Element v) /* (R *Element, wasSquare int) */ {
    final t0 = Element.feZero();

    // r = (u * v3) * (u * v7)^((p-5)/8)
    final v2 = Element.feZero()..square(v);
    final uv3 = Element.feZero()..multiply(u, t0..multiply(v2, v));
    final uv7 = Element.feZero()..multiply(uv3, t0..square(v2));
    final rr = Element.feZero()..multiply(uv3, t0..pow22523(uv7));

    final check = Element.feZero()
      ..multiply(v, t0..square(rr)); // check = v * r^2

    final uNeg = Element.feZero()..negate(u);
    final correctSignSqrt = check.equal(u);
    final flippedSignSqrt = check.equal(uNeg);
    final flippedSignSqrtI = check.equal(t0..multiply(uNeg, Element.sqrtM1()));

    final rPrime = Element.feZero()
      ..multiply(rr, Element.sqrtM1()); // r_prime = SQRT_M1 * r
    // r = CT_SELECT(r_prime IF flipped_sign_sqrt | flipped_sign_sqrt_i ELSE r)
    rr.select(rPrime, rr, flippedSignSqrt | flippedSignSqrtI);

    absolute(rr); // Choose the nonnegative square root.
    return (this, correctSignSqrt | flippedSignSqrt);
  }

  //
  //
  // ------------ Generics ------------
  //

  ///
  /// Limb multiplication works like pen-and-paper columnar multiplication, but
  /// with 51-bit limbs instead of digits.
  ///
  ///                          a4   a3   a2   a1   a0  x
  ///                          b4   b3   b2   b1   b0  =
  ///                         ------------------------
  ///                        a4b0 a3b0 a2b0 a1b0 a0b0  +
  ///                   a4b1 a3b1 a2b1 a1b1 a0b1       +
  ///              a4b2 a3b2 a2b2 a1b2 a0b2            +
  ///         a4b3 a3b3 a2b3 a1b3 a0b3                 +
  ///    a4b4 a3b4 a2b4 a1b4 a0b4                      =
  ///   ----------------------------------------------
  ///      r8   r7   r6   r5   r4   r3   r2   r1   r0
  ///
  /// We can then use the reduction identity (a * 2²⁵⁵ + b = a * 19 + b) to
  /// reduce the limbs that would overflow 255 bits. r5 * 2²⁵⁵ becomes 19 * r5,
  /// r6 * 2³⁰⁶ becomes 19 * r6 * 2⁵¹, etc.
  ///
  /// Reduction can be carried out simultaneously to multiplication. For
  /// example, we do not compute r5: whenever the result of a multiplication
  /// belongs to r5, like a1b4, we multiply it by 19 and add the result to r0.
  ///
  ///            a4b0    a3b0    a2b0    a1b0    a0b0  +
  ///            a3b1    a2b1    a1b1    a0b1 19×a4b1  +
  ///            a2b2    a1b2    a0b2 19×a4b2 19×a3b2  +
  ///            a1b3    a0b3 19×a4b3 19×a3b3 19×a2b3  +
  ///            a0b4 19×a4b4 19×a3b4 19×a2b4 19×a1b4  =
  ///           --------------------------------------
  ///              r4      r3      r2      r1      r0
  ///
  /// Finally we add up the columns into wide, overlapping limbs.
  void feMulGeneric(Element a, Element b) {
    final a1_19 = a.l1 * bigInt19;
    final a2_19 = a.l2 * bigInt19;
    final a3_19 = a.l3 * bigInt19;
    final a4_19 = a.l4 * bigInt19;

    // r0 = a0×b0 + 19×(a1×b4 + a2×b3 + a3×b2 + a4×b1)
    final r0 = Uint128.mul64(a.l0, b.l0)
      ..addMul64(a1_19, b.l4)
      ..addMul64(a2_19, b.l3)
      ..addMul64(a3_19, b.l2)
      ..addMul64(a4_19, b.l1);

    // r1 = a0×b1 + a1×b0 + 19×(a2×b4 + a3×b3 + a4×b2)
    final r1 = Uint128.mul64(a.l0, b.l1)
      ..addMul64(a.l1, b.l0)
      ..addMul64(a2_19, b.l4)
      ..addMul64(a3_19, b.l3)
      ..addMul64(a4_19, b.l2);

    // r2 = a0×b2 + a1×b1 + a2×b0 + 19×(a3×b4 + a4×b3)
    final r2 = Uint128.mul64(a.l0, b.l2)
      ..addMul64(a.l1, b.l1)
      ..addMul64(a.l2, b.l0)
      ..addMul64(a3_19, b.l4)
      ..addMul64(a4_19, b.l3);

    // r3 = a0×b3 + a1×b2 + a2×b1 + a3×b0 + 19×a4×b4
    final r3 = Uint128.mul64(a.l0, b.l3)
      ..addMul64(a.l1, b.l2)
      ..addMul64(a.l2, b.l1)
      ..addMul64(a.l3, b.l0)
      ..addMul64(a4_19, b.l4);

    // r4 = a0×b4 + a1×b3 + a2×b2 + a3×b1 + a4×b0
    final r4 = Uint128.mul64(a.l0, b.l4)
      ..addMul64(a.l1, b.l3)
      ..addMul64(a.l2, b.l2)
      ..addMul64(a.l3, b.l1)
      ..addMul64(a.l4, b.l0);

    // After the multiplication, we need to reduce (carry) the five coefficients
    // to obtain a result with limbs that are at most slightly larger than 2⁵¹,
    // to respect the Element invariant.
    //
    // Overall, the reduction works the same as carryPropagate, except with
    // wider inputs: we take the carry for each coefficient by shifting it right
    // by 51, and add it to the limb above it. The top carry is multiplied by 19
    // according to the reduction identity and added to the lowest limb.
    //
    // The largest coefficient (r0) will be at most 111 bits, which guarantees
    // that all carries are at most 111 - 51 = 60 bits, which fits in a uint64.
    //
    //     r0 = a0×b0 + 19×(a1×b4 + a2×b3 + a3×b2 + a4×b1)
    //     r0 < 2⁵²×2⁵² + 19×(2⁵²×2⁵² + 2⁵²×2⁵² + 2⁵²×2⁵² + 2⁵²×2⁵²)
    //     r0 < (1 + 19 × 4) × 2⁵² × 2⁵²
    //     r0 < 2⁷ × 2⁵² × 2⁵²
    //     r0 < 2¹¹¹
    //
    // Moreover, the top coefficient (r4) is at most 107 bits, so c4 is at most
    // 56 bits, and c4 * 19 is at most 61 bits, which again fits in a uint64 and
    // allows us to easily apply the reduction identity.
    //
    //     r4 = a0×b4 + a1×b3 + a2×b2 + a3×b1 + a4×b0
    //     r4 < 5 × 2⁵² × 2⁵²
    //     r4 < 2¹⁰⁷
    //

    final c0 = r0.shiftRightBy51();
    final c1 = r1.shiftRightBy51();
    final c2 = r2.shiftRightBy51();
    final c3 = r3.shiftRightBy51();
    final c4 = r4.shiftRightBy51();

    final rr0 = (r0.low & maskLow51Bits) + (c4 * bigInt19);
    final rr1 = (r1.low & maskLow51Bits) + c0;
    final rr2 = (r2.low & maskLow51Bits) + c1;
    final rr3 = (r3.low & maskLow51Bits) + c2;
    final rr4 = (r4.low & maskLow51Bits) + c3;

    // Now all coefficients fit into 64-bit registers but are still too large to
    // be passed around as a Element. We therefore do one last carry chain,
    // where the carries will be small enough to fit in the wiggle room above 2⁵¹.
    l0 = rr0;
    l1 = rr1;
    l2 = rr2;
    l3 = rr3;
    l4 = rr4;

    carryPropagateGeneric();
  }

  /// Squaring works precisely like multiplication above, but thanks to its
  /// symmetry we get to group a few terms together.
  ///
  ///                          l4   l3   l2   l1   l0  x
  ///                          l4   l3   l2   l1   l0  =
  ///                         ------------------------
  ///                        l4l0 l3l0 l2l0 l1l0 l0l0  +
  ///                   l4l1 l3l1 l2l1 l1l1 l0l1       +
  ///              l4l2 l3l2 l2l2 l1l2 l0l2            +
  ///         l4l3 l3l3 l2l3 l1l3 l0l3                 +
  ///    l4l4 l3l4 l2l4 l1l4 l0l4                      =
  ///   ----------------------------------------------
  ///      r8   r7   r6   r5   r4   r3   r2   r1   r0
  ///
  ///            l4l0    l3l0    l2l0    l1l0    l0l0  +
  ///            l3l1    l2l1    l1l1    l0l1 19×l4l1  +
  ///            l2l2    l1l2    l0l2 19×l4l2 19×l3l2  +
  ///            l1l3    l0l3 19×l4l3 19×l3l3 19×l2l3  +
  ///            l0l4 19×l4l4 19×l3l4 19×l2l4 19×l1l4  =
  ///           --------------------------------------
  ///              r4      r3      r2      r1      r0
  ///
  /// With precomputed 2×, 19×, and 2×19× terms, we can compute each limb with
  /// only three Mul64 and four Add64, instead of five and eight.
  void feSquareGeneric(Element a) {
    final l0_2 = a.l0 * BigInt.two;
    final l1_2 = a.l1 * BigInt.two;

    final l1_38 = a.l1 * 38.toBigInt;
    final l2_38 = a.l2 * 38.toBigInt;
    final l3_38 = a.l3 * 38.toBigInt;

    final l3_19 = a.l3 * bigInt19;
    final l4_19 = a.l4 * bigInt19;

    // r0 = l0×l0 + 19×(l1×l4 + l2×l3 + l3×l2 + l4×l1) = l0×l0 + 19×2×(l1×l4 + l2×l3)
    final r0 = Uint128.mul64(a.l0, a.l0)
      ..addMul64(l1_38, a.l4)
      ..addMul64(l2_38, a.l3);

    // r1 = l0×l1 + l1×l0 + 19×(l2×l4 + l3×l3 + l4×l2) = 2×l0×l1 + 19×2×l2×l4 + 19×l3×l3
    final r1 = Uint128.mul64(l0_2, a.l1)
      ..addMul64(l2_38, a.l4)
      ..addMul64(l3_19, a.l3);

    // r2 = l0×l2 + l1×l1 + l2×l0 + 19×(l3×l4 + l4×l3) = 2×l0×l2 + l1×l1 + 19×2×l3×l4
    final r2 = Uint128.mul64(l0_2, a.l2)
      ..addMul64(a.l1, a.l1)
      ..addMul64(l3_38, a.l4);

    // r3 = l0×l3 + l1×l2 + l2×l1 + l3×l0 + 19×l4×l4 = 2×l0×l3 + 2×l1×l2 + 19×l4×l4
    final r3 = Uint128.mul64(l0_2, a.l3)
      ..addMul64(l1_2, a.l2)
      ..addMul64(l4_19, a.l4);

    // r4 = l0×l4 + l1×l3 + l2×l2 + l3×l1 + l4×l0 = 2×l0×l4 + 2×l1×l3 + l2×l2
    final r4 = Uint128.mul64(l0_2, a.l4)
      ..addMul64(l1_2, a.l3)
      ..addMul64(a.l2, a.l2);

    final c0 = r0.shiftRightBy51();
    final c1 = r1.shiftRightBy51();
    final c2 = r2.shiftRightBy51();
    final c3 = r3.shiftRightBy51();
    final c4 = r4.shiftRightBy51();

    final rr0 = (r0.low & maskLow51Bits) + (c4 * bigInt19);
    final rr1 = (r1.low & maskLow51Bits) + c0;
    final rr2 = (r2.low & maskLow51Bits) + c1;
    final rr3 = (r3.low & maskLow51Bits) + c2;
    final rr4 = (r4.low & maskLow51Bits) + c3;

    l0 = rr0;
    l1 = rr1;
    l2 = rr2;
    l3 = rr3;
    l4 = rr4;

    carryPropagateGeneric();
  }

  /// carryPropagate brings the limbs below 52 bits by applying the reduction
  /// identity (a * 2²⁵⁵ + b = a * 19 + b) to the l4 carry.
  void carryPropagateGeneric() {
    final BigInt c0 = l0 >> 51;
    final BigInt c1 = l1 >> 51;
    final BigInt c2 = l2 >> 51;
    final BigInt c3 = l3 >> 51;
    final BigInt c4 = l4 >> 51;

    // c4 is at most 64 - 51 = 13 bits, so c4*19 is at most 18 bits, and
    // the final l0 will be at most 52 bits. Similarly for the rest.
    l0 = (l0 & maskLow51Bits) + (c4 * bigInt19);
    l1 = (l1 & maskLow51Bits) + c0;
    l2 = (l2 & maskLow51Bits) + c1;
    l3 = (l3 & maskLow51Bits) + c2;
    l4 = (l4 & maskLow51Bits) + c3;
  }

  void fromDecimal(String s) {
    fromBigInt(s.toBigInt());
  }

  /// fromBig sets v = n, and returns v. The bit length of n must not exceed 256.
  void fromBigInt(BigInt n) {
    if (n.bitLength > 32 * 8) {
      throw ArgumentError("edwards25519: invalid field element input size");
    }

    final uint8List = Uint8List(32);

    for (int i = 0; i < 32; i++) {
      uint8List[i] = (n >> (i * 8)).toUnsigned(8).toInt();
    }
    setBytes(uint8List);
  }

  /// converts the field element to a big integer.
  BigInt toBigInt() {
    List<int> buf = Bytes();
    BigInt result = BigInt.zero;

    for (int i = buf.length - 1; i >= 0; i--) {
      // Shift the result left by 8 bits.
      // OR the next byte into the result.
      result = (result << 8) | BigInt.from(buf[i]);
    }

    return result;
  }

  /// This file contains additional functionality that is not included in the
  /// upstream crypto/ed25519/edwards25519/field package.
  ///
  /// SetWideBytes sets v to x, where x is a 64-byte little-endian encoding, which
  /// is reduced modulo the field order. If x is not of the right length,
  /// SetWideBytes returns nil and an error, and the receiver is unchanged.
  ///
  /// SetWideBytes is not necessary to select a uniformly distributed value, and is
  /// only provided for compatibility: SetBytes can be used instead as the chance
  /// of bias is less than 2⁻²⁵⁰.
  void setWideBytes(Uint8List x) {
    if (x.length != 64) {
      throw ArgumentError("edwards25519: invalid SetWideBytes input size");
    }

    // Split the 64 bytes into two elements, and extract the most significant
    // bit of each, which is ignored by SetBytes.
    final lo = Element.feZero()..setBytes(x.sublist(0, 32));
    final loMSB = (x[31] >> 7).toBigInt;
    final hi = Element.feZero()..setBytes(x.sublist(32));
    final hiMSB = (x[63] >> 7).toBigInt;

    // The output we want is
    //
    //   v = lo + loMSB * 2²⁵⁵ + hi * 2²⁵⁶ + hiMSB * 2⁵¹¹
    //
    // which applying the reduction identity comes out to
    //
    //   v = lo + loMSB * 19 + hi * 2 * 19 + hiMSB * 2 * 19²
    //
    // l0 will be the sum of a 52 bits value (lo.l0), plus a 5 bits value
    // (loMSB * 19), a 6 bits value (hi.l0 * 2 * 19), and a 10 bits value
    // (hiMSB * 2 * 19²), so it fits in a uint64.

    l0 = lo.l0 +
        (loMSB * bigInt19) +
        (hi.l0 * BigInt.two * bigInt19) +
        (hiMSB * BigInt.two * bigInt19 * bigInt19);
    l1 = lo.l1 + (hi.l1 * BigInt.two * bigInt19);
    l2 = lo.l2 + (hi.l2 * BigInt.two * bigInt19);
    l3 = lo.l3 + (hi.l3 * BigInt.two * bigInt19);
    l4 = lo.l4 + (hi.l4 * BigInt.two * bigInt19);
    carryPropagateGeneric();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Element &&
          runtimeType == other.runtimeType &&
          l0 == other.l0 &&
          l1 == other.l1 &&
          l2 == other.l2 &&
          l3 == other.l3 &&
          l4 == other.l4;

  @override
  int get hashCode =>
      l0.hashCode ^ l1.hashCode ^ l2.hashCode ^ l3.hashCode ^ l4.hashCode;

  @override
  String toString() {
    return '''Element(
          l0: $l0,
          l1: $l1,
          l2: $l2,
          l3: $l3,
          l4: $l4,
)''';
  }
}
