part of edwards25519;

/// uint128 holds a 128-bit number as two 64-bit limbs, for use with the
/// bits.Mul64 and bits.Add64 intrinsics.
class Uint128 {
  BigInt low;
  BigInt high;
  Uint128(this.low, this.high);

  /// mul64 returns a * b.
  factory Uint128.mul64(BigInt a, BigInt b) {
    final (high, low) = Bits.mul64(a, b);
    return Uint128(low, high);
  }

  /// addMul64 returns v + a * b.
  void addMul64(BigInt a, BigInt b) {
    final (h, l) = Bits.mul64(a, b);
    final (lo, c) = Bits.add64(l, low, 0);
    final (hi, _) = Bits.add64(h, high, c);
    low = lo;
    high = hi;
  }

  /// shiftRightBy51 returns a >> 51. a is assumed to be at most 115 bits.
  BigInt shiftRightBy51() {
    return (high << (64 - 51)) | (low >> 51);
  }
}
