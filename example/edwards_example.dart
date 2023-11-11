import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:edwards25519/edwards25519.dart';

void main() {
  final p1 = Point.zero()
    ..setBytes(Uint8List.fromList(hex.decode(
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')));

  final p2 = Point.zero()
    ..setBytes(Uint8List.fromList(hex.decode(
        '1200000000000000000000000000000000000000000000000000000000000080')));

  // if returns 1 then it is equal, 0 otherwise
  final isEqual = p1.equal(p2) == 1;
  print('isEqual: $isEqual');

  final res = hex.encode(p1.Bytes());
  // res: 1200000000000000000000000000000000000000000000000000000000000080
  print('res: $res');
}
