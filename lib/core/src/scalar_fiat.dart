part of edwards25519;

typedef fiatScalarUint1 = BigInt;
// We use uint64 instead of a more narrow type for performance reasons; see https://github.com/mit-plv/fiat-crypto/pull/1006#issuecomment-892625927

/// The type fiatScalarMontgomeryDomainFieldElement is a field element in the Montgomery domain.
///
/// Bounds: [[0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff]]
typedef fiatScalarMontgomeryDomainFieldElement = List<BigInt>;

/// The type fiatScalarNonMontgomeryDomainFieldElement is a field element NOT in the Montgomery domain.
///
/// Bounds: [[0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff]]
typedef fiatScalarNonMontgomeryDomainFieldElement = List<BigInt>;

/// fiatScalarCmovznzU64 is a single-word conditional move.
///
/// Postconditions:
///   out1 = (if arg1 = 0 then arg2 else arg3)
///
/// Input Bounds:
///   arg1: [0x0 ~> 0x1]
///   arg2: [0x0 ~> 0xffffffffffffffff]
///   arg3: [0x0 ~> 0xffffffffffffffff]
/// Output Bounds:
///   out1: [0x0 ~> 0xffffffffffffffff]
BigInt fiatScalarCmovznzU64(BigInt arg1, BigInt arg2, BigInt arg3) {
  final BigInt x1 = arg1 * BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16);
  final BigInt x2 = ((x1 & arg3) | ((~x1) & arg2));
  return x2;
}

/// fiatScalarMul multiplies two field elements in the Montgomery domain.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
///   0 ≤ eval arg2 < m
/// Postconditions:
///   eval (from_montgomery out1) mod m = (eval (from_montgomery arg1) * eval (from_montgomery arg2)) mod m
///   0 ≤ eval out1 < m
///
void fiatScalarMul(
    fiatScalarMontgomeryDomainFieldElement out1,
    fiatScalarMontgomeryDomainFieldElement arg1,
    fiatScalarMontgomeryDomainFieldElement arg2) {
  final x1 = arg1[1];
  final x2 = arg1[2];
  final x3 = arg1[3];
  final x4 = arg1[0];

  final (BigInt x6, BigInt x5) = Bits.mul64(x4, arg2[3]);

  final (BigInt x8, BigInt x7) = Bits.mul64(x4, arg2[2]);

  final (BigInt x10, BigInt x9) = Bits.mul64(x4, arg2[1]);

  final (BigInt x12, BigInt x11) = Bits.mul64(x4, arg2[0]);

  final (BigInt x13, int x14) = Bits.add64(x12, x9, 0);

  final (BigInt x15, int x16) = Bits.add64(x10, x7, x14);

  final (BigInt x17, int x18) = Bits.add64(x8, x5, x16);

  final BigInt x19 = (x18.toBigInt + x6);

  final (_, BigInt x20) = Bits.mul64(x11, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x23, BigInt x22) =
      Bits.mul64(x20, '1000000000000000'.toBigInt(16));

  final (BigInt x25, BigInt x24) =
      Bits.mul64(x20, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x27, BigInt x26) =
      Bits.mul64(x20, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x28, int x29) = Bits.add64(x27, x24, 0);

  final BigInt x30 = (x29.toBigInt + x25);

  final (_, int x32) = Bits.add64(x11, x26, 0);

  final (BigInt x33, int x34) = Bits.add64(x13, x28, x32);

  final (BigInt x35, int x36) = Bits.add64(x15, x30, x34);

  final (BigInt x37, int x38) = Bits.add64(x17, x22, x36);

  final (BigInt x39, int x40) = Bits.add64(x19, x23, x38);

  final (BigInt x42, BigInt x41) = Bits.mul64(x1, arg2[3]);

  final (BigInt x44, BigInt x43) = Bits.mul64(x1, arg2[2]);

  final (BigInt x46, BigInt x45) = Bits.mul64(x1, arg2[1]);

  final (BigInt x48, BigInt x47) = Bits.mul64(x1, arg2[0]);

  final (BigInt x49, int x50) = Bits.add64(x48, x45, 0);

  final (BigInt x51, int x52) = Bits.add64(x46, x43, x50);

  final (BigInt x53, int x54) = Bits.add64(x44, x41, x52);
  final x55 = (x54.toBigInt + x42);

  final (BigInt x56, int x57) = Bits.add64(x33, x47, 0);

  final (BigInt x58, int x59) = Bits.add64(x35, x49, x57);

  final (BigInt x60, int x61) = Bits.add64(x37, x51, x59);

  final (BigInt x62, int x63) = Bits.add64(x39, x53, x61);

  final (BigInt x64, int x65) = Bits.add64(x40.toBigInt, x55, x63);

  final (_, BigInt x66) = Bits.mul64(x56, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x69, BigInt x68) =
      Bits.mul64(x66, '1000000000000000'.toBigInt(16));

  final (BigInt x71, BigInt x70) =
      Bits.mul64(x66, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x73, BigInt x72) =
      Bits.mul64(x66, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x74, int x75) = Bits.add64(x73, x70, 0);
  final x76 = (x75.toBigInt + x71);

  final (_, int x78) = Bits.add64(x56, x72, 0);

  final (BigInt x79, int x80) = Bits.add64(x58, x74, x78);

  final (BigInt x81, int x82) = Bits.add64(x60, x76, x80);

  final (BigInt x83, int x84) = Bits.add64(x62, x68, x82);

  final (BigInt x85, int x86) = Bits.add64(x64, x69, x84);
  final x87 = (x86.toBigInt + x65.toBigInt);

  final (BigInt x89, BigInt x88) = Bits.mul64(x2, arg2[3]);

  final (BigInt x91, BigInt x90) = Bits.mul64(x2, arg2[2]);

  final (BigInt x93, BigInt x92) = Bits.mul64(x2, arg2[1]);

  final (BigInt x95, BigInt x94) = Bits.mul64(x2, arg2[0]);

  final (BigInt x96, int x97) = Bits.add64(x95, x92, 0);

  final (BigInt x98, int x99) = Bits.add64(x93, x90, x97);

  final (BigInt x100, int x101) = Bits.add64(x91, x88, x99);
  final x102 = (x101.toBigInt + x89);

  final (BigInt x103, int x104) = Bits.add64(x79, x94, 0);

  final (BigInt x105, int x106) = Bits.add64(x81, x96, x104);

  final (BigInt x107, int x108) = Bits.add64(x83, x98, x106);

  final (BigInt x109, int x110) = Bits.add64(x85, x100, x108);

  final (BigInt x111, int x112) = Bits.add64(x87, x102, x110);

  final (_, BigInt x113) = Bits.mul64(x103, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x116, BigInt x115) =
      Bits.mul64(x113, '1000000000000000'.toBigInt(16));

  final (BigInt x118, BigInt x117) =
      Bits.mul64(x113, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x120, BigInt x119) =
      Bits.mul64(x113, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x121, int x122) = Bits.add64(x120, x117, 0);
  final x123 = (x122.toBigInt + x118);

  final (_, int x125) = Bits.add64(x103, x119, 0);

  final (BigInt x126, int x127) = Bits.add64(x105, x121, x125);

  final (BigInt x128, int x129) = Bits.add64(x107, x123, x127);

  final (BigInt x130, int x131) = Bits.add64(x109, x115, x129);

  final (BigInt x132, int x133) = Bits.add64(x111, x116, x131);
  final x134 = (x133 + x112);

  final (BigInt x136, BigInt x135) = Bits.mul64(x3, arg2[3]);

  final (BigInt x138, BigInt x137) = Bits.mul64(x3, arg2[2]);

  final (BigInt x140, BigInt x139) = Bits.mul64(x3, arg2[1]);

  final (BigInt x142, BigInt x141) = Bits.mul64(x3, arg2[0]);

  final (BigInt x143, int x144) = Bits.add64(x142, x139, 0);

  final (BigInt x145, int x146) = Bits.add64(x140, x137, x144);

  final (BigInt x147, int x148) = Bits.add64(x138, x135, x146);
  final x149 = (x148.toBigInt + x136);

  final (BigInt x150, int x151) = Bits.add64(x126, x141, 0);

  final (BigInt x152, int x153) = Bits.add64(x128, x143, x151);

  final (BigInt x154, int x155) = Bits.add64(x130, x145, x153);

  final (BigInt x156, int x157) = Bits.add64(x132, x147, x155);

  final (BigInt x158, int x159) = Bits.add64(x134.toBigInt, x149, x157);

  final (_, BigInt x160) = Bits.mul64(x150, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x163, BigInt x162) =
      Bits.mul64(x160, '1000000000000000'.toBigInt(16));

  final (BigInt x165, BigInt x164) =
      Bits.mul64(x160, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x167, BigInt x166) =
      Bits.mul64(x160, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x168, int x169) = Bits.add64(x167, x164, 0);
  final x170 = (x169.toBigInt + x165);

  final (_, int x172) = Bits.add64(x150, x166, 0);

  final (BigInt x173, int x174) = Bits.add64(x152, x168, x172);

  final (BigInt x175, int x176) = Bits.add64(x154, x170, x174);

  final (BigInt x177, int x178) = Bits.add64(x156, x162, x176);

  final (BigInt x179, int x180) = Bits.add64(x158, x163, x178);
  final x181 = (x180 + x159);

  final (BigInt x182, int x183) =
      Bits.sub64(x173, '5812631a5cf5d3ed'.toBigInt(16), 0);

  final (BigInt x184, int x185) =
      Bits.sub64(x175, '14def9dea2f79cd6'.toBigInt(16), x183);

  final (BigInt x186, int x187) = Bits.sub64(x177, BigInt.zero, x185);

  final (BigInt x188, int x189) =
      Bits.sub64(x179, '1000000000000000'.toBigInt(16), x187);

  final (_, int x191) = Bits.sub64(x181.toBigInt, BigInt.zero, x189);
  final BigInt x192 = fiatScalarCmovznzU64(x191.toBigInt, x182, x173);
  final BigInt x193 = fiatScalarCmovznzU64(x191.toBigInt, x184, x175);
  final BigInt x194 = fiatScalarCmovznzU64(x191.toBigInt, x186, x177);
  final BigInt x195 = fiatScalarCmovznzU64(x191.toBigInt, x188, x179);
  out1[0] = x192;
  out1[1] = x193;
  out1[2] = x194;
  out1[3] = x195;
}

/// fiatScalarAdd adds two field elements in the Montgomery domain.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
///   0 ≤ eval arg2 < m
/// Postconditions:
///   eval (from_montgomery out1) mod m = (eval (from_montgomery arg1) + eval (from_montgomery arg2)) mod m
///   0 ≤ eval out1 < m
void fiatScalarAdd(
    fiatScalarMontgomeryDomainFieldElement out1,
    fiatScalarMontgomeryDomainFieldElement arg1,
    fiatScalarMontgomeryDomainFieldElement arg2) {
  final (BigInt x1, int x2) = Bits.add64(arg1[0], arg2[0], 0);

  final (BigInt x3, int x4) = Bits.add64(arg1[1], arg2[1], x2);

  final (BigInt x5, int x6) = Bits.add64(arg1[2], arg2[2], x4);

  final (BigInt x7, int x8) = Bits.add64(arg1[3], arg2[3], x6);

  final (BigInt x9, int x10) =
      Bits.sub64(x1, '5812631a5cf5d3ed'.toBigInt(16), 0);

  final (BigInt x11, int x12) =
      Bits.sub64(x3, '14def9dea2f79cd6'.toBigInt(16), x10);

  final (BigInt x13, int x14) = Bits.sub64(x5, BigInt.zero, x12);

  final (BigInt x15, int x16) =
      Bits.sub64(x7, '1000000000000000'.toBigInt(16), x14);

  final (_, int x18) = Bits.sub64(x8.toBigInt, BigInt.zero, x16);

  final x19 = fiatScalarCmovznzU64(x18.toBigInt, x9, x1);

  final x20 = fiatScalarCmovznzU64(x18.toBigInt, x11, x3);

  final x21 = fiatScalarCmovznzU64(x18.toBigInt, x13, x5);

  final x22 = fiatScalarCmovznzU64(x18.toBigInt, x15, x7);
  out1[0] = x19;
  out1[1] = x20;
  out1[2] = x21;
  out1[3] = x22;
}

/// fiatScalarSub subtracts two field elements in the Montgomery domain.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
///   0 ≤ eval arg2 < m
/// Postconditions:
///   eval (from_montgomery out1) mod m = (eval (from_montgomery arg1) - eval (from_montgomery arg2)) mod m
///   0 ≤ eval out1 < m
void fiatScalarSub(
    fiatScalarMontgomeryDomainFieldElement out1,
    fiatScalarMontgomeryDomainFieldElement arg1,
    fiatScalarMontgomeryDomainFieldElement arg2) {
  final (BigInt x1, int x2) = Bits.sub64(arg1[0], arg2[0], 0);

  final (BigInt x3, int x4) = Bits.sub64(arg1[1], arg2[1], x2);

  final (BigInt x5, int x6) = Bits.sub64(arg1[2], arg2[2], x4);

  final (BigInt x7, int x8) = Bits.sub64(arg1[3], arg2[3], x6);

  final x9 = fiatScalarCmovznzU64(
      x8.toBigInt, BigInt.zero, 'ffffffffffffffff'.toBigInt(16));

  final (BigInt x10, int x11) =
      Bits.add64(x1, (x9 & '5812631a5cf5d3ed'.toBigInt(16)), 0);

  final (BigInt x12, int x13) =
      Bits.add64(x3, (x9 & '14def9dea2f79cd6'.toBigInt(16)), x11);

  final (BigInt x14, int x15) = Bits.add64(x5, BigInt.zero, x13);

  final (BigInt x16, int _) =
      Bits.add64(x7, (x9 & '1000000000000000'.toBigInt(16)), x15);

  out1[0] = x10;
  out1[1] = x12;
  out1[2] = x14;
  out1[3] = x16;
}

/// fiatScalarOpp negates a field element in the Montgomery domain.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
/// Postconditions:
///   eval (from_montgomery out1) mod m = -eval (from_montgomery arg1) mod m
///   0 ≤ eval out1 < m
///
void fiatScalarOpp(fiatScalarMontgomeryDomainFieldElement out1,
    fiatScalarMontgomeryDomainFieldElement arg1) {
  final (BigInt x1, int x2) = Bits.sub64(BigInt.zero, arg1[0], 0);

  final (BigInt x3, int x4) = Bits.sub64(BigInt.zero, arg1[1], x2);

  final (BigInt x5, int x6) = Bits.sub64(BigInt.zero, arg1[2], x4);

  final (BigInt x7, int x8) = Bits.sub64(BigInt.zero, arg1[3], x6);

  final x9 = fiatScalarCmovznzU64(
      x8.toBigInt, BigInt.zero, 'ffffffffffffffff'.toBigInt(16));

  final (BigInt x10, int x11) =
      Bits.add64(x1, (x9 & '5812631a5cf5d3ed'.toBigInt(16)), 0);

  final (BigInt x12, int x13) =
      Bits.add64(x3, (x9 & '14def9dea2f79cd6'.toBigInt(16)), x11);

  final (BigInt x14, int x15) = Bits.add64(x5, BigInt.zero, x13);

  final (BigInt x16, int _) =
      Bits.add64(x7, (x9 & '1000000000000000'.toBigInt(16)), x15);
  out1[0] = x10;
  out1[1] = x12;
  out1[2] = x14;
  out1[3] = x16;
}

/// fiatScalarNonzero outputs a single non-zero word if the input is non-zero and zero otherwise.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
/// Postconditions:
///   out1 = 0 ↔ eval (from_montgomery arg1) mod m = 0
///
/// Input Bounds:
///   arg1: [[0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff]]
/// Output Bounds:
///   out1: [0x0 ~> 0xffffffffffffffff]
BigInt fiatScalarNonzero(List<BigInt> arg1) {
  return (arg1[0] | (arg1[1] | (arg1[2] | arg1[3])));
}

/// fiatScalarFromMontgomery translates a field element out of the Montgomery domain.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
/// Postconditions:
///   eval out1 mod m = (eval arg1 * ((2^64)⁻¹ mod m)^4) mod m
///   0 ≤ eval out1 < m
void fiatScalarFromMontgomery(fiatScalarNonMontgomeryDomainFieldElement out1,
    fiatScalarMontgomeryDomainFieldElement arg1) {
  final x1 = arg1[0];

  final (_, BigInt x2) = Bits.mul64(x1, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x5, BigInt x4) =
      Bits.mul64(x2, '1000000000000000'.toBigInt(16));

  final (BigInt x7, BigInt x6) =
      Bits.mul64(x2, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x9, BigInt x8) =
      Bits.mul64(x2, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x10, int x11) = Bits.add64(x9, x6, 0);

  final (_, int x13) = Bits.add64(x1, x8, 0);

  final (BigInt x14, int x15) = Bits.add64(BigInt.zero, x10, x13);

  final (BigInt x16, int x17) = Bits.add64(x14, arg1[1], 0);

  final (_, BigInt x18) = Bits.mul64(x16, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x21, BigInt x20) =
      Bits.mul64(x18, '1000000000000000'.toBigInt(16));

  final (BigInt x23, BigInt x22) =
      Bits.mul64(x18, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x25, BigInt x24) =
      Bits.mul64(x18, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x26, int x27) = Bits.add64(x25, x22, 0);

  final (_, int x29) = Bits.add64(x16, x24, 0);

  final (BigInt x30, int x31) = Bits.add64(
      (x17.toBigInt + (x15.toBigInt + (x11.toBigInt + x7))), x26, x29);

  final (BigInt x32, int x33) = Bits.add64(x4, (x27.toBigInt + x23), x31);

  final (BigInt x34, int x35) = Bits.add64(x5, x20, x33);

  final (BigInt x36, int x37) = Bits.add64(x30, arg1[2], 0);

  final (BigInt x38, int x39) = Bits.add64(x32, BigInt.zero, x37);

  final (BigInt x40, int x41) = Bits.add64(x34, BigInt.zero, x39);

  final (_, BigInt x42) = Bits.mul64(x36, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x45, BigInt x44) =
      Bits.mul64(x42, '1000000000000000'.toBigInt(16));

  final (BigInt x47, BigInt x46) =
      Bits.mul64(x42, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x49, BigInt x48) =
      Bits.mul64(x42, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x50, int x51) = Bits.add64(x49, x46, 0);

  final (_, int x53) = Bits.add64(x36, x48, 0);

  final (BigInt x54, int x55) = Bits.add64(x38, x50, x53);

  final (BigInt x56, int x57) = Bits.add64(x40, (x51.toBigInt + x47), x55);

  final (BigInt x58, int x59) =
      Bits.add64((x41.toBigInt + (x35.toBigInt + x21)), x44, x57);

  final (BigInt x60, int x61) = Bits.add64(x54, arg1[3], 0);

  final (BigInt x62, int x63) = Bits.add64(x56, BigInt.zero, x61);

  final (BigInt x64, int x65) = Bits.add64(x58, BigInt.zero, x63);

  final (_, BigInt x66) = Bits.mul64(x60, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x69, BigInt x68) =
      Bits.mul64(x66, '1000000000000000'.toBigInt(16));

  final (BigInt x71, BigInt x70) =
      Bits.mul64(x66, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x73, BigInt x72) =
      Bits.mul64(x66, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x74, int x75) = Bits.add64(x73, x70, 0);

  final (_, int x77) = Bits.add64(x60, x72, 0);

  final (BigInt x78, int x79) = Bits.add64(x62, x74, x77);

  final (BigInt x80, int x81) = Bits.add64(x64, (x75.toBigInt + x71), x79);

  final (BigInt x82, int x83) =
      Bits.add64((x65.toBigInt + (x59.toBigInt + x45)), x68, x81);
  final x84 = (x83.toBigInt + x69);

  final (BigInt x85, int x86) =
      Bits.sub64(x78, '5812631a5cf5d3ed'.toBigInt(16), 0);

  final (BigInt x87, int x88) =
      Bits.sub64(x80, '14def9dea2f79cd6'.toBigInt(16), x86);

  final (BigInt x89, int x90) = Bits.sub64(x82, BigInt.zero, x88);

  final (BigInt x91, int x92) =
      Bits.sub64(x84, '1000000000000000'.toBigInt(16), x90);

  final (_, int x94) = Bits.sub64(BigInt.zero, BigInt.zero, x92);

  final x95 = fiatScalarCmovznzU64(x94.toBigInt, x85, x78);

  final x96 = fiatScalarCmovznzU64(x94.toBigInt, x87, x80);

  final x97 = fiatScalarCmovznzU64(x94.toBigInt, x89, x82);

  final x98 = fiatScalarCmovznzU64(x94.toBigInt, x91, x84);

  out1[0] = x95;
  out1[1] = x96;
  out1[2] = x97;
  out1[3] = x98;
}

/// fiatScalarToMontgomery translates a field element into the Montgomery domain.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
/// Postconditions:
///   eval (from_montgomery out1) mod m = eval arg1 mod m
///   0 ≤ eval out1 < m
///
void fiatScalarToMontgomery(fiatScalarMontgomeryDomainFieldElement out1,
    fiatScalarNonMontgomeryDomainFieldElement arg1) {
  final BigInt x1 = arg1[1];
  final BigInt x2 = arg1[2];
  final BigInt x3 = arg1[3];
  final BigInt x4 = arg1[0];

  final (BigInt x6, BigInt x5) = Bits.mul64(x4, '399411b7c309a3d'.toBigInt(16));

  final (BigInt x8, BigInt x7) =
      Bits.mul64(x4, 'ceec73d217f5be65'.toBigInt(16));

  final (BigInt x10, BigInt x9) =
      Bits.mul64(x4, 'd00e1ba768859347'.toBigInt(16));

  final (BigInt x12, BigInt x11) =
      Bits.mul64(x4, 'a40611e3449c0f01'.toBigInt(16));

  final (BigInt x13, int x14) = Bits.add64(x12, x9, 0);

  final (BigInt x15, int x16) = Bits.add64(x10, x7, x14);

  final (BigInt x17, int x18) = Bits.add64(x8, x5, x16);

  final (_, BigInt x19) = Bits.mul64(x11, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x22, BigInt x21) =
      Bits.mul64(x19, '1000000000000000'.toBigInt(16));

  final (BigInt x24, BigInt x23) =
      Bits.mul64(x19, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x26, BigInt x25) =
      Bits.mul64(x19, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x27, int x28) = Bits.add64(x26, x23, 0);

  final (_, int x30) = Bits.add64(x11, x25, 0);

  final (BigInt x31, int x32) = Bits.add64(x13, x27, x30);

  final (BigInt x33, int x34) = Bits.add64(x15, (x28.toBigInt + x24), x32);

  final (BigInt x35, int x36) = Bits.add64(x17, x21, x34);

  final (BigInt x38, BigInt x37) =
      Bits.mul64(x1, '399411b7c309a3d'.toBigInt(16));

  final (BigInt x40, BigInt x39) =
      Bits.mul64(x1, 'ceec73d217f5be65'.toBigInt(16));

  final (BigInt x42, BigInt x41) =
      Bits.mul64(x1, 'd00e1ba768859347'.toBigInt(16));

  final (BigInt x44, BigInt x43) =
      Bits.mul64(x1, 'a40611e3449c0f01'.toBigInt(16));

  final (BigInt x45, int x46) = Bits.add64(x44, x41, 0);

  final (BigInt x47, int x48) = Bits.add64(x42, x39, x46);

  final (BigInt x49, int x50) = Bits.add64(x40, x37, x48);

  final (BigInt x51, int x52) = Bits.add64(x31, x43, 0);

  final (BigInt x53, int x54) = Bits.add64(x33, x45, x52);

  final (BigInt x55, int x56) = Bits.add64(x35, x47, x54);

  final (BigInt x57, int x58) =
      Bits.add64(((x36.toBigInt + (x18.toBigInt + x6)) + x22), x49, x56);

  final (_, BigInt x59) = Bits.mul64(x51, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x62, BigInt x61) =
      Bits.mul64(x59, '1000000000000000'.toBigInt(16));

  final (BigInt x64, BigInt x63) =
      Bits.mul64(x59, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x66, BigInt x65) =
      Bits.mul64(x59, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x67, int x68) = Bits.add64(x66, x63, 0);

  final (_, int x70) = Bits.add64(x51, x65, 0);

  final (BigInt x71, int x72) = Bits.add64(x53, x67, x70);

  final (BigInt x73, int x74) = Bits.add64(x55, (x68.toBigInt + x64), x72);

  final (BigInt x75, int x76) = Bits.add64(x57, x61, x74);

  final (BigInt x78, BigInt x77) =
      Bits.mul64(x2, '399411b7c309a3d'.toBigInt(16));

  final (BigInt x80, BigInt x79) =
      Bits.mul64(x2, 'ceec73d217f5be65'.toBigInt(16));

  final (BigInt x82, BigInt x81) =
      Bits.mul64(x2, 'd00e1ba768859347'.toBigInt(16));

  final (BigInt x84, BigInt x83) =
      Bits.mul64(x2, 'a40611e3449c0f01'.toBigInt(16));

  final (BigInt x85, int x86) = Bits.add64(x84, x81, 0);

  final (BigInt x87, int x88) = Bits.add64(x82, x79, x86);

  final (BigInt x89, int x90) = Bits.add64(x80, x77, x88);

  final (BigInt x91, int x92) = Bits.add64(x71, x83, 0);

  final (BigInt x93, int x94) = Bits.add64(x73, x85, x92);

  final (BigInt x95, int x96) = Bits.add64(x75, x87, x94);

  final (BigInt x97, int x98) = Bits.add64(
      ((x76.toBigInt + (x58.toBigInt + (x50.toBigInt + x38))) + x62), x89, x96);

  final (_, BigInt x99) = Bits.mul64(x91, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x102, BigInt x101) =
      Bits.mul64(x99, '1000000000000000'.toBigInt(16));

  final (BigInt x104, BigInt x103) =
      Bits.mul64(x99, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x106, BigInt x105) =
      Bits.mul64(x99, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x107, int x108) = Bits.add64(x106, x103, 0);

  final (_, int x110) = Bits.add64(x91, x105, 0);

  final (BigInt x111, int x112) = Bits.add64(x93, x107, x110);

  final (BigInt x113, int x114) = Bits.add64(x95, (x108.toBigInt + x104), x112);

  final (BigInt x115, int x116) = Bits.add64(x97, x101, x114);

  final (BigInt x118, BigInt x117) =
      Bits.mul64(x3, '399411b7c309a3d'.toBigInt(16));

  final (BigInt x120, BigInt x119) =
      Bits.mul64(x3, 'ceec73d217f5be65'.toBigInt(16));

  final (BigInt x122, BigInt x121) =
      Bits.mul64(x3, 'd00e1ba768859347'.toBigInt(16));

  final (BigInt x124, BigInt x123) =
      Bits.mul64(x3, 'a40611e3449c0f01'.toBigInt(16));

  final (BigInt x125, int x126) = Bits.add64(x124, x121, 0);

  final (BigInt x127, int x128) = Bits.add64(x122, x119, x126);

  final (BigInt x129, int x130) = Bits.add64(x120, x117, x128);

  final (BigInt x131, int x132) = Bits.add64(x111, x123, 0);

  final (BigInt x133, int x134) = Bits.add64(x113, x125, x132);

  final (BigInt x135, int x136) = Bits.add64(x115, x127, x134);

  final (BigInt x137, int x138) = Bits.add64(
      ((x116.toBigInt + (x98.toBigInt + (x90.toBigInt + x78))) + x102),
      x129,
      x136);

  final (_, BigInt x139) = Bits.mul64(x131, 'd2b51da312547e1b'.toBigInt(16));

  final (BigInt x142, BigInt x141) =
      Bits.mul64(x139, '1000000000000000'.toBigInt(16));

  final (BigInt x144, BigInt x143) =
      Bits.mul64(x139, '14def9dea2f79cd6'.toBigInt(16));

  final (BigInt x146, BigInt x145) =
      Bits.mul64(x139, '5812631a5cf5d3ed'.toBigInt(16));

  final (BigInt x147, int x148) = Bits.add64(x146, x143, 0);

  final (_, int x150) = Bits.add64(x131, x145, 0);

  final (BigInt x151, int x152) = Bits.add64(x133, x147, x150);

  final (BigInt x153, int x154) =
      Bits.add64(x135, (x148.toBigInt + x144), x152);

  final (BigInt x155, int x156) = Bits.add64(x137, x141, x154);
  final x157 =
      ((x156.toBigInt + (x138.toBigInt + (x130.toBigInt + x118))) + x142);

  final (BigInt x158, int x159) =
      Bits.sub64(x151, '5812631a5cf5d3ed'.toBigInt(16), 0);

  final (BigInt x160, int x161) =
      Bits.sub64(x153, '14def9dea2f79cd6'.toBigInt(16), x159);

  final (BigInt x162, int x163) = Bits.sub64(x155, BigInt.zero, x161);

  final (BigInt x164, int x165) =
      Bits.sub64(x157, '1000000000000000'.toBigInt(16), x163);

  final (_, int x167) = Bits.sub64(BigInt.zero, BigInt.zero, x165);

  final x168 = fiatScalarCmovznzU64(x167.toBigInt, x158, x151);

  final x169 = fiatScalarCmovznzU64(x167.toBigInt, x160, x153);

  final x170 = fiatScalarCmovznzU64(x167.toBigInt, x162, x155);

  final x171 = fiatScalarCmovznzU64(x167.toBigInt, x164, x157);
  out1[0] = x168;
  out1[1] = x169;
  out1[2] = x170;
  out1[3] = x171;
}

/// fiatScalarToBytes serializes a field element NOT in the Montgomery domain to bytes in little-endian order.
///
/// Preconditions:
///   0 ≤ eval arg1 < m
/// Postconditions:
///   out1 = map (λ x, ⌊((eval arg1 mod m) mod 2^(8 * (x + 1))) / 2^(8 * x)⌋) [0..31]
///
/// Input Bounds:
///   arg1: [[0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0x1fffffffffffffff]]
/// Output Bounds:
///   out1: [[0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0x1f]]
void fiatScalarToBytes(List<int> out1, List<BigInt> arg1) {
  final x1 = arg1[3];
  final x2 = arg1[2];
  final x3 = arg1[1];
  final x4 = arg1[0];
  final x5 = (x4.toUnsigned(8).toInt());
  final x6 = (x4 >> 8);
  final x7 = (x6.toUnsigned(8).toInt());
  final x8 = (x6 >> 8);
  final x9 = (x8.toUnsigned(8).toInt());
  final x10 = (x8 >> 8);
  final x11 = (x10.toUnsigned(8).toInt());
  final x12 = (x10 >> 8);
  final x13 = (x12.toUnsigned(8).toInt());
  final x14 = (x12 >> 8);
  final x15 = (x14.toUnsigned(8).toInt());
  final x16 = (x14 >> 8);
  final x17 = (x16.toUnsigned(8).toInt());
  final x18 = (x16 >> 8).toInt();
  final x19 = (x3.toUnsigned(8).toInt());
  final x20 = (x3 >> 8);
  final x21 = (x20.toUnsigned(8).toInt());
  final x22 = (x20 >> 8);
  final x23 = (x22.toUnsigned(8).toInt());
  final x24 = (x22 >> 8);
  final x25 = (x24.toUnsigned(8).toInt());
  final x26 = (x24 >> 8);
  final x27 = (x26.toUnsigned(8).toInt());
  final x28 = (x26 >> 8);
  final x29 = (x28.toUnsigned(8).toInt());
  final x30 = (x28 >> 8);
  final x31 = (x30.toUnsigned(8).toInt());
  final x32 = (x30 >> 8).toInt();
  final x33 = (x2.toUnsigned(8).toInt());
  final x34 = (x2 >> 8);
  final x35 = (x34.toUnsigned(8).toInt());
  final x36 = (x34 >> 8);
  final x37 = (x36.toUnsigned(8).toInt());
  final x38 = (x36 >> 8);
  final x39 = (x38.toUnsigned(8).toInt());
  final x40 = (x38 >> 8);
  final x41 = (x40.toUnsigned(8).toInt());
  final x42 = (x40 >> 8);
  final x43 = (x42.toUnsigned(8).toInt());
  final x44 = (x42 >> 8);
  final x45 = (x44.toUnsigned(8).toInt());
  final x46 = (x44 >> 8).toInt();
  final x47 = (x1.toUnsigned(8).toInt());
  final x48 = (x1 >> 8);
  final x49 = (x48.toUnsigned(8).toInt());
  final x50 = (x48 >> 8);
  final x51 = (x50.toUnsigned(8).toInt());
  final x52 = (x50 >> 8);
  final x53 = (x52.toUnsigned(8).toInt());
  final x54 = (x52 >> 8);
  final x55 = (x54.toUnsigned(8).toInt());
  final x56 = (x54 >> 8);
  final x57 = (x56.toUnsigned(8).toInt());
  final x58 = (x56 >> 8);
  final x59 = (x58.toUnsigned(8).toInt());
  final x60 = (x58 >> 8).toInt();
  out1[0] = x5;
  out1[1] = x7;
  out1[2] = x9;
  out1[3] = x11;
  out1[4] = x13;
  out1[5] = x15;
  out1[6] = x17;
  out1[7] = x18;
  out1[8] = x19;
  out1[9] = x21;
  out1[10] = x23;
  out1[11] = x25;
  out1[12] = x27;
  out1[13] = x29;
  out1[14] = x31;
  out1[15] = x32;
  out1[16] = x33;
  out1[17] = x35;
  out1[18] = x37;
  out1[19] = x39;
  out1[20] = x41;
  out1[21] = x43;
  out1[22] = x45;
  out1[23] = x46;
  out1[24] = x47;
  out1[25] = x49;
  out1[26] = x51;
  out1[27] = x53;
  out1[28] = x55;
  out1[29] = x57;
  out1[30] = x59;
  out1[31] = x60;
}

/// fiatScalarFromBytes deserializes a field element NOT in the Montgomery domain from bytes in little-endian order.
///
/// Preconditions:
///   0 ≤ bytes_eval arg1 < m
/// Postconditions:
///   eval out1 mod m = bytes_eval arg1 mod m
///   0 ≤ eval out1 < m
///
/// Input Bounds:
///   arg1: [[0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0xff], [0x0 ~> 0x1f]]
/// Output Bounds:
///   out1: [[0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0xffffffffffffffff], [0x0 ~> 0x1fffffffffffffff]]
void fiatScalarFromBytes(List<BigInt> out1, List<int> arg1) {
  final x1 = (arg1[31].toBigInt << 56);
  final x2 = (arg1[30].toBigInt << 48);
  final x3 = (arg1[29].toBigInt << 40);
  final x4 = (arg1[28].toBigInt << 32);
  final x5 = (arg1[27].toBigInt << 24);
  final x6 = (arg1[26].toBigInt << 16);
  final x7 = (arg1[25].toBigInt << 8);
  final x8 = arg1[24];
  final x9 = (arg1[23].toBigInt << 56);
  final x10 = (arg1[22].toBigInt << 48);
  final x11 = (arg1[21].toBigInt << 40);
  final x12 = (arg1[20].toBigInt << 32);
  final x13 = (arg1[19].toBigInt << 24);
  final x14 = (arg1[18].toBigInt << 16);
  final x15 = (arg1[17].toBigInt << 8);
  final x16 = arg1[16];
  final x17 = (arg1[15].toBigInt << 56);
  final x18 = (arg1[14].toBigInt << 48);
  final x19 = (arg1[13].toBigInt << 40);
  final x20 = (arg1[12].toBigInt << 32);
  final x21 = (arg1[11].toBigInt << 24);
  final x22 = (arg1[10].toBigInt << 16);
  final x23 = (arg1[9].toBigInt << 8);
  final x24 = arg1[8];
  final x25 = (arg1[7].toBigInt << 56);
  final x26 = (arg1[6].toBigInt << 48);
  final x27 = (arg1[5].toBigInt << 40);
  final x28 = (arg1[4].toBigInt << 32);
  final x29 = (arg1[3].toBigInt << 24);
  final x30 = (arg1[2].toBigInt << 16);
  final x31 = (arg1[1].toBigInt << 8);
  final x32 = arg1[0];
  final x33 = (x31 + x32.toBigInt);
  final x34 = (x30 + x33);
  final x35 = (x29 + x34);
  final x36 = (x28 + x35);
  final x37 = (x27 + x36);
  final x38 = (x26 + x37);
  final x39 = (x25 + x38);
  final x40 = (x23 + x24.toBigInt);
  final x41 = (x22 + x40);
  final x42 = (x21 + x41);
  final x43 = (x20 + x42);
  final x44 = (x19 + x43);
  final x45 = (x18 + x44);
  final x46 = (x17 + x45);
  final x47 = (x15 + x16.toBigInt);
  final x48 = (x14 + x47);
  final x49 = (x13 + x48);
  final x50 = (x12 + x49);
  final x51 = (x11 + x50);
  final x52 = (x10 + x51);
  final x53 = (x9 + x52);
  final x54 = (x7 + x8.toBigInt);
  final x55 = (x6 + x54);
  final x56 = (x5 + x55);
  final x57 = (x4 + x56);
  final x58 = (x3 + x57);
  final x59 = (x2 + x58);
  final x60 = (x1 + x59);
  out1[0] = x39;
  out1[1] = x46;
  out1[2] = x53;
  out1[3] = x60;
}
