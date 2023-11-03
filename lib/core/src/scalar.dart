part of edwards25519;

/// A Scalar is an integer modulo
///
///	l = 2^252 + 27742317777372353535851937790883648493
///
/// which is the prime order of the edwards25519 group.
///
/// This type works similarly to math/big.Int, and all arguments and
/// receivers are allowed to alias.
///
/// The zero value is a valid zero element.
class Scalar {
  /// s is the scalar in the Montgomery domain, in the format of the
  /// fiat-crypto implementation.
  final fiatScalarMontgomeryDomainFieldElement s =
      List.generate(4, (_) => BigInt.zero, growable: false);

  Scalar.parametrized(List<BigInt> arg) {
    s[0] = arg[0];
    s[1] = arg[1];
    s[2] = arg[2];
    s[3] = arg[3];
  }

  /// returns a new zero Scalar.
  Scalar();

  factory Scalar.from(Scalar other) {
    return Scalar()..copyFrom(other);
  }

  void copyFrom(Scalar other) {
    s[0] = other.s[0];
    s[1] = other.s[1];
    s[2] = other.s[2];
    s[3] = other.s[3];
  }

  /// MultiplyAdd sets s = x * y + z mod l, and returns s. It is equivalent to
  /// using Multiply and then Add.
  void multiplyAdd(Scalar x, Scalar y, Scalar z) {
    // Make a copy of z in case it aliases s.
    final zCopy = Scalar()..set(z);
    multiply(x, y);
    add(this, zCopy);
  }

  /// Add sets s = x + y mod l, and returns s.
  void add(Scalar x, Scalar y) {
    // s = 1 * x + y mod l
    fiatScalarAdd(s, x.s, y.s);
  }

  /// Subtract sets s = x - y mod l, and returns s.
  void subtract(Scalar x, Scalar y) {
    // s = -1 * y + x mod l
    fiatScalarSub(s, x.s, y.s);
  }

  /// Negate sets s = -x mod l, and returns s.
  void negate(Scalar x) {
    // s = -1 * x + 0 mod l
    fiatScalarOpp(s, x.s);
  }

  /// Multiply sets this = x * y mod l
  void multiply(Scalar x, Scalar y) {
    // s = x * y + 0 mod l
    fiatScalarMul(s, x.s, y.s);
  }

  /// Set sets s = x, and returns s.
  void set(Scalar x) {
    s[0] = x.s[0];
    s[1] = x.s[1];
    s[2] = x.s[2];
    s[3] = x.s[3];
  }

  /// SetUniformBytes sets s = x mod l, where x is a 64-byte little-endian integer.
  /// If x is not of the right length, SetUniformBytes returns nil and an error,
  /// and the receiver is unchanged.
  ///
  /// SetUniformBytes can be used to set s to an uniformly distributed value given
  /// 64 uniformly distributed random bytes.
  void setUniformBytes(List<int> x) {
    if (x.length != 64) {
      //return nil, errors.New("edwards25519: invalid SetUniformBytes input length")
      throw ArgumentError("edwards25519: invalid setUniformBytes input length");
    }

    // We have a value x of 512 bits, but our fiatScalarFromBytes function
    // expects an input lower than l, which is a little over 252 bits.
    //
    // Instead of writing a reduction function that operates on wider inputs, we
    // can interpret x as the sum of three shorter values a, b, and c.
    //
    //    x = a + b * 2^168 + c * 2^336  mod l
    //
    // We then precompute 2^168 and 2^336 modulo l, and perform the reduction
    // with two multiplications and two additions.

    setShortBytes(x.sublist(0, 21));
    final t = Scalar()..setShortBytes(x.sublist(21, 42));
    add(this, t..multiply(t, scalarTwo168));
    t.setShortBytes(x.sublist(42, 64));
    add(this, t..multiply(t, scalarTwo336));
  }

  /// scalarTwo168 and scalarTwo336 are 2^168 and 2^336 modulo l, encoded as a
  /// fiatScalarMontgomeryDomainFieldElement, which is a little-endian 4-limb value
  /// in the 2^256 Montgomery domain.
  static final scalarTwo168 = Scalar.parametrized(<BigInt>[
    '5b8ab432eac74798'.toBigInt(16),
    '38afddd6de59d5d7'.toBigInt(16),
    'a2c131b399411b7c'.toBigInt(16),
    '6329a7ed9ce5a30'.toBigInt(16),
  ]);

  /// scalarTwo168 and scalarTwo336 are 2^168 and 2^336 modulo l, encoded as a
  /// fiatScalarMontgomeryDomainFieldElement, which is a little-endian 4-limb value
  /// in the 2^256 Montgomery domain.
  static final scalarTwo336 = Scalar.parametrized(<BigInt>[
    'bd3d108e2b35ecc5'.toBigInt(16),
    '5c3a3718bdf9c90b'.toBigInt(16),
    '63aa97a331b4f2ee'.toBigInt(16),
    '3d217f5be65cb5c'.toBigInt(16),
  ]);

  /// setShortBytes sets s = x mod l, where x is a little-endian integer shorter
  /// than 32 bytes.
  void setShortBytes(List<int> x) {
    if (x.length >= 32) {
      throw ArgumentError(
          "edwards25519: internal error: setShortBytes called with a long string");
    }

    List<int> buf = List<int>.filled(32, 0, growable: false);
    buf.setAll(0, x);
    fiatScalarFromBytes(s, buf);
    fiatScalarToMontgomery(s, s);
  }

  /// SetCanonicalBytes sets s = x, where x is a 32-byte little-endian encoding of
  /// s, and returns s. If x is not a canonical encoding of s, SetCanonicalBytes
  /// returns nil and an error, and the receiver is unchanged.
  void setCanonicalBytes(List<int> x) {
    if (x.length != 32) {
      throw ArgumentError("edwards25519: invalid scalar length");
    }
    if (!isReduced(x)) {
      throw ArgumentError("edwards25519: invalid scalar encoding");
    }

    fiatScalarFromBytes(s, x);
    fiatScalarToMontgomery(s, s);
  }

  /// scalarMinusOneBytes is l - 1 in little endian.
  static final scalarMinusOneBytes = <int>[
    236,
    211,
    245,
    92,
    26,
    99,
    18,
    88,
    214,
    156,
    247,
    162,
    222,
    249,
    222,
    20,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    16
  ];

  /// isReduced returns whether the given scalar in 32-byte little endian encoded
  /// form is reduced modulo l.
  static bool isReduced(List<int> s) {
    if (s.length != 32) {
      return false;
    }

    for (int i = s.length - 1; i >= 0; i--) {
      if (s[i] > scalarMinusOneBytes[i]) {
        return false;
      } else if (s[i] < scalarMinusOneBytes[i]) {
        return true;
      }
    }
    return true;
  }

  /// SetBytesWithClamping applies the buffer pruning described in RFC 8032,
  /// Section 5.1.5 (also known as clamping) and sets s to the result. The input
  /// must be 32 bytes, and it is not modified. If x is not of the right length,
  /// SetBytesWithClamping returns nil and an error, and the receiver is unchanged.
  ///
  /// Note that since Scalar values are always reduced modulo the prime order of
  /// the curve, the resulting value will not preserve any of the cofactor-clearing
  /// properties that clamping is meant to provide. It will however work as
  /// expected as long as it is applied to points on the prime order subgroup, like
  /// in Ed25519. In fact, it is lost to history why RFC 8032 adopted the
  /// irrelevant RFC 7748 clamping, but it is now required for compatibility.
  void setBytesWithClamping(List<int> x) {
    // The description above omits the purpose of the high bits of the clamping
    // for brevity, but those are also lost to reductions, and are also
    // irrelevant to edwards25519 as they protect against a specific
    // implementation bug that was once observed in a generic Montgomery ladder.
    if (x.length != 32) {
      throw ArgumentError(
          "edwards25519: invalid SetBytesWithClamping input length");
    }

    // We need to use the wide reduction from SetUniformBytes, since clamping
    // sets the 2^254 bit, making the value higher than the order.
    final wideBytes = List<int>.filled(64, 0, growable: false);
    wideBytes.setAll(0, x);
    wideBytes[0] &= 248;
    wideBytes[31] &= 63;
    wideBytes[31] |= 64;
    setUniformBytes(wideBytes);
  }

  /// Bytes returns the canonical 32-byte little-endian encoding of s.
  Uint8List Bytes() {
    // This function is outlined to make the allocations inline in the caller
    // rather than happen on the heap.
    final Uint8List encoded = Uint8List(32);
    return bytes(encoded);
  }

  Uint8List bytes(Uint8List out) {
    final fiatScalarNonMontgomeryDomainFieldElement ss =
        List.filled(4, BigInt.zero, growable: false);
    fiatScalarFromMontgomery(ss, s);
    fiatScalarToBytes(out, ss);
    return out;
  }

  /// Equal returns 1 if s and t are equal, and 0 otherwise.
  int equal(Scalar t) {
    final fiatScalarMontgomeryDomainFieldElement diff =
        List.filled(4, BigInt.zero, growable: false);
    fiatScalarSub(diff, s, t.s);
    BigInt nonzero = fiatScalarNonzero(diff);
    nonzero |= nonzero >> 32;
    nonzero |= nonzero >> 16;
    nonzero |= nonzero >> 8;
    nonzero |= nonzero >> 4;
    nonzero |= nonzero >> 2;
    nonzero |= nonzero >> 1;
    return ((~nonzero) & BigInt.one).toInt();
  }

  /// nonAdjacentForm computes a width-w non-adjacent form for this scalar.
  ///
  /// w must be between 2 and 8, or nonAdjacentForm will panic.
  List<int> nonAdjacentForm(int w) {
    // This implementation is adapted from the one
    // in curve25519-dalek and is documented there:
    // https://github.com/dalek-cryptography/curve25519-dalek/blob/f630041af28e9a405255f98a8a93adca18e4315b/src/scalar.rs#L800-L871
    final Uint8List b = Bytes();
    if (b[31] > 127) {
      throw ArgumentError("edwards25519: scalar has high bit set illegally");
    }
    if (w < 2) {
      throw ArgumentError(
          "edwards25519: w must be at least 2 by the definition of NAF");
    } else if (w > 8) {
      throw ArgumentError("edwards25519: NAF digits must fit in int8");
    }

    List<int> naf = List<int>.filled(256, 0, growable: false);
    List<BigInt> digits = List<BigInt>.filled(5, BigInt.zero, growable: false);
    {
      // Little Endian conversion here
      for (int i = 0; i < 4; i++) {
        int startIndex = i * 8;
        Uint8List slice = b.sublist(startIndex, startIndex + 8);
        BigInt value = BigInt.from(0);

        for (int j = 7; j >= 0; j--) {
          value += BigInt.from(slice[j]) << (j * 8);
        }

        digits[i] = value;
      }
    }

    final width = (1 << w).toBigInt;
    final windowMask = width - BigInt.one;

    int pos = 0;
    BigInt carry = BigInt.zero;
    while (pos < 256) {
      final int indexU64 = (pos / 64).floor();
      final int indexBit = (pos % 64);
      BigInt bitBuf;
      if (indexBit < 64 - w) {
        // This window's bits are contained in a single u64
        bitBuf = digits[indexU64] >> indexBit;
      } else {
        // Combine the current 64 bits with bits from the next 64
        bitBuf = (digits[indexU64] >> indexBit) |
            (digits[1 + indexU64] << (64 - indexBit));
      }

      // Add carry into the current window
      final window = carry + (bitBuf & windowMask);

      if (window & BigInt.one == BigInt.zero) {
        // If the window value is even, preserve the carry and continue.
        // Why is the carry preserved?
        // If carry == 0 and window & 1 == 0,
        //    then the next carry should be 0
        // If carry == 1 and window & 1 == 0,
        //    then bit_buf & 1 == 1 so the next carry should be 1
        pos += 1;
        continue;
      }

      if (window < (width / BigInt.two).floor().toBigInt) {
        carry = BigInt.zero;
        naf[pos] = window.toInt();
      } else {
        carry = BigInt.one;
        naf[pos] = (window - width).toInt();
      }

      pos += w;
    }
    return naf;
  }

  List<int> signedRadix16() {
    final b = Bytes();
    if (b[31] > 127) {
      throw ArgumentError("edwards25519: scalar has high bit set illegally");
    }

    final digits = List<int>.filled(64, 0, growable: false);

    // Compute unsigned radix-16 digits:
    for (int i = 0; i < 32; i++) {
      digits[2 * i] = (b[i] & 15).toSigned(8);
      digits[2 * i + 1] = ((b[i] >> 4) & 15).toSigned(8);
    }

    // Recenter coefficients:
    for (int i = 0; i < 63; i++) {
      final carry = (digits[i] + 8) >> 4;
      digits[i] -= carry << 4;
      digits[i + 1] += carry;
    }

    return digits;
  }

  /// Given k > 0, set s = s**(2*k).
  void pow2k(int k) {
    for (var i = 0; i < k; i++) {
      multiply(this, this);
    }
  }

  /// Invert sets s to the inverse of a nonzero scalar v, and returns s.
  ///
  /// If t is zero, Invert returns zero.
  void Invert(Scalar t) {
    // Uses a hardcoded sliding window of width 4.
    List<Scalar> table = List.generate(8, (_) => Scalar(), growable: false);
    Scalar tt = Scalar();
    tt.multiply(t, t);
    table[0] = Scalar.from(t);
    for (var i = 0; i < 7; i++) {
      table[i + 1].multiply(table[i], tt);
    }
    // Now table = [t**1, t**3, t**5, t**7, t**9, t**11, t**13, t**15]
    // so t**k = t[k/2] for odd k

    // To compute the sliding window digits, use the following Sage script:

    // sage: import itertools
    // sage: def sliding_window(w,k):
    // ....:     digits = []
    // ....:     while k > 0:
    // ....:         if k % 2 == 1:
    // ....:             kmod = k % (2**w)
    // ....:             digits.append(kmod)
    // ....:             k = k - kmod
    // ....:         else:
    // ....:             digits.append(0)
    // ....:         k = k // 2
    // ....:     return digits

    // Now we can compute s roughly as follows:

    // sage: s = 1
    // sage: for coeff in reversed(sliding_window(4,l-2)):
    // ....:     s = s*s
    // ....:     if coeff > 0 :
    // ....:         s = s*t**coeff

    // This works on one bit at a time, with many runs of zeros.
    // The digits can be collapsed into [(count, coeff)] as follows:

    // sage: [(len(list(group)),d) for d,group in itertools.groupby(sliding_window(4,l-2))]

    // Entries of the form (k, 0) turn into pow2k(k)
    // Entries of the form (1, coeff) turn into a squaring and then a table lookup.
    // We can fold the squaring into the previous pow2k(k) as pow2k(k+1).

    copyFrom(tt); // 0
    pow2k(126 + 1);
    multiply(this, table[0]); // 0
    pow2k(4 + 1);
    multiply(this, table[4]); // 4
    pow2k(3 + 1);
    multiply(this, table[5]); // 11/2 = 5
    pow2k(3 + 1);
    multiply(this, table[6]); // 13/2 = 6
    pow2k(3 + 1);
    multiply(this, table[7]); // 15/2 = 7
    pow2k(4 + 1);
    multiply(this, table[3]); // 7/2 = 3
    pow2k(4 + 1);
    multiply(this, table[7]); // 15/2 = 7
    pow2k(3 + 1);
    multiply(this, table[2]); // 5/2 = 2
    pow2k(3 + 1);
    multiply(this, table[0]); // 1/2 = 0
    pow2k(4 + 1);
    multiply(this, table[7]); // 15/2 = 7
    pow2k(4 + 1);
    multiply(this, table[7]); // 15/2 = 7
    pow2k(4 + 1);
    multiply(this, table[3]); // 7/2 = 3
    pow2k(3 + 1);
    multiply(this, table[1]); // 3/2 = 1
    pow2k(4 + 1);
    multiply(this, table[5]); // 11/2 = 5
    pow2k(5 + 1);
    multiply(this, table[5]); // 11/2 = 5
    pow2k(9 + 1);
    multiply(this, table[4]); // 9/2 = 4
    pow2k(3 + 1);
    multiply(this, table[1]); // 3/2 = 1
    pow2k(4 + 1);
    multiply(this, table[1]); // 3/2 = 1
    pow2k(4 + 1);
    multiply(this, table[1]); // 3/2 = 1
    pow2k(4 + 1);
    multiply(this, table[4]); // 9/2 = 4
    pow2k(3 + 1);
    multiply(this, table[3]); // 7/2 = 3
    pow2k(3 + 1);
    multiply(this, table[1]); // 3/2 = 1
    pow2k(3 + 1);
    multiply(this, table[6]); // 13/2 = 6
    pow2k(3 + 1);
    multiply(this, table[3]); // 7/2 = 3
    pow2k(4 + 1);
    multiply(this, table[4]); // 9/2 = 4
    pow2k(3 + 1);
    multiply(this, table[7]); // 15/2 = 7
    pow2k(4 + 1);
    multiply(this, table[5]); // 11/2 = 5
  }
}
