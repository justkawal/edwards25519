part of edwards25519;

extension IntExtension on int {
  /// converts an int to a BigInt.
  BigInt get toBigInt => BigInt.from(this);
}

extension ListIntExtension on List<int> {
  /// fills a byte array with the bytes to create a BigInt.
  void fillBytes(BigInt n) {
    for (int i = length - 1; i >= 0; i--) {
      if (n == BigInt.zero) break;
      this[i] = (n & BigInt.from(0xFF)).toInt();
      n = n >> 8;
    }
  }

  /// in-place swapEndianness swaps the endianness of a byte array.
  void swapEndianness() {
    for (int i = 0; i < length ~/ 2; i++) {
      final int temp = this[i];
      final position = length - i - 1;
      this[i] = this[position];
      this[position] = temp;
    }
  }

  /// bytesToBigInt converts a byte array to a BigInt.
  BigInt toBigInt() {
    BigInt result = BigInt.zero;
    for (int i = 0; i < length; i++) {
      result = (result << 8) | BigInt.from(this[i]);
    }
    return result;
  }
}

extension StringExtension on String {
  /// converts string to BigInt
  BigInt toBigInt([int? radix]) => BigInt.parse(this, radix: radix);
}
