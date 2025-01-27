part of edwards25519;

final BigInt _mask32 = (BigInt.one << 32) - BigInt.one;
final BigInt _mask64 = (BigInt.one << 64) - BigInt.one;

class Bits {
  /// Mul64 returns the 128-bit product of x and y: (hi, lo) = x * y
  /// with the product bits' upper half returned in hi and the lower
  /// half returned in lo.
  ///
  /// This function's execution time does not depend on the inputs.
  static (BigInt high, BigInt low) mul64(BigInt x, BigInt y) {
    final BigInt x0 = x & _mask32;
    final BigInt x1 = x >> 32;
    final BigInt y0 = y & _mask32;
    final BigInt y1 = y >> 32;
    final BigInt w0 = x0 * y0;
    final BigInt t = x1 * y0 + (w0 >> 32);
    BigInt w1 = t & _mask32;
    final BigInt w2 = t >> 32;
    w1 += x0 * y1;
    final BigInt high =
        ((x1 * y1) & BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16)) +
            w2 +
            ((w1 >> 32));
    final BigInt low = (x * y) & _mask64;
    return (high, low);
  }

  /// Add64 returns the sum with carry of x, y and carry: sum = x + y + carry.
  /// The carry input must be 0 or 1; otherwise the behavior is undefined.
  /// The carryOut output is guaranteed to be 0 or 1.
  ///
  /// This function's execution time does not depend on the inputs.
  static (BigInt sum, int carryOut) add64(BigInt x, BigInt y, int carry) {
    final BigInt sum = (x + y + BigInt.from(carry)) &
        BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16); // Apply modulo 2^64
    // The sum will overflow if both top bits are set (x & y) or if one of them
    // is (x | y), and a carry from the lower place happened. If such a carry
    // happens, the top bit will be 1 + 0 + 1 = 0 (&^ sum).
    final carryOut = ((x & y) | ((x | y) & ~sum)) >> 63;
    return (sum, carryOut.toInt());
  }

  /// Sub64 returns the difference of x, y and borrow: diff = x - y - borrow.
  /// The borrow input must be 0 or 1; otherwise the behavior is undefined.
  /// The borrowOut output is guaranteed to be 0 or 1.
  ///
  /// This function's execution time does not depend on the inputs.
  static (BigInt diff, int borrowOut) sub64(BigInt x, BigInt y, int borrow) {
    final BigInt diff = (x - y - BigInt.from(borrow)) &
        BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16); // Apply modulo 2^64
    final borrowOut = ((~x & y) | ((~x | y) & diff)) >> 63;
    return (diff, borrowOut.toInt());
  }
}
