part of edwards25519;

int constantTimeCompare(List<int> x, List<int> y) {
  if (x.length != y.length) {
    return 0;
  }

  int v = 0;
  for (int i = 0; i < x.length; i++) {
    v |= (x[i] ^ y[i]);
  }

  return constantTimeByteEq(v, 0);
}

int constantTimeByteEq(int x, int y) {
  return (x ^ y) == 0 ? 1 : 0;
}
