part of edwards25519;

class basepointNafTablePrecomp {
  basepointNafTablePrecomp._() {
    table.fromP3(Point.newGeneratorPoint());
  }

  final nafLookupTable8 table = nafLookupTable8();

  static final basepointNafTablePrecomp _instance =
      basepointNafTablePrecomp._();

  static basepointNafTablePrecomp get instance => _instance;
}
