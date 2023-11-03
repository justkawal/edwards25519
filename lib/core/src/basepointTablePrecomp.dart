part of edwards25519;

class basepointTablePrecomp {
  basepointTablePrecomp._() {
    // Only initializing the table once
    final p = Point.newGeneratorPoint();
    for (int i = 0; i < 32; i++) {
      table[i].fromP3(p);
      for (int j = 0; j < 8; j++) {
        p.add(p, p);
      }
    }
  }

  final List<affineLookupTable> table =
      List<affineLookupTable>.generate(32, (_) => affineLookupTable());

  static final basepointTablePrecomp _instance = basepointTablePrecomp._();

  static basepointTablePrecomp get instance => _instance;
}
