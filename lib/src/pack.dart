// 'A' - 1
const baseChar = 0x41 - 1;

int packCodes(String a2, String a3, int n) {
  var a2c = a2.codeUnits;
  var a3c = a3.codeUnits;
  if ((1 << 32) != 0) {
    return (a2c[0] - baseChar) << 30 |
        (a2c[1] - baseChar) << 25 |
        (a3c[0] - baseChar) << 20 |
        (a3c[1] - baseChar) << 15 |
        (a3c[2] - baseChar) << 10 |
        n;
  } else {
    return (a2c[0] - baseChar) * 0x40000000 + 
        ((a2c[1] - baseChar) << 25 |
        (a3c[0] - baseChar) << 20 |
        (a3c[1] - baseChar) << 15 |
        (a3c[2] - baseChar) << 10 |
        n);
  }
}

int packAlpha2(String a2) {
  var cu = a2.codeUnits;
  if ((1 << 32) != 0) {
    return (cu[0] - baseChar) << 30 | (cu[1] - baseChar) << 25;
  } else {
    return ((cu[0] - baseChar) * 0x40000000) + ((cu[1] - baseChar) << 25);
  }
}

int packAlpha2i(int c0, int c1) {
  if ((1 << 32) != 0) {
    return (c0 - baseChar) << 30 | (c1 - baseChar) << 25;
  } else {
    return (c0 - baseChar) * 0x40000000 + (c1 - baseChar) << 25;
  }
}

String unpackAlpha2(int i) {
  final _a2Code = <int>[0, 0];

  if ((1 << 32) != 0) {
    _a2Code[0] = baseChar + ((i >> 30));
  } else {
    _a2Code[0] = baseChar + (i ~/ 0x40000000);
  }
    
  _a2Code[1] = baseChar + ((i >> 25) & 0x1F);
  return String.fromCharCodes(_a2Code);
}

void unpackAlpha2i(int i, List<int> cu) {
  // hack to avoid 32-bit truncating in JS
  if ((1 << 32) != 0) {
    cu[0] = baseChar + ((i >> 30));
  } else {
    cu[0] = baseChar + (i ~/ 0x40000000);
  }  
  cu[1] = baseChar + ((i >> 25) & 0x1F);
}

int packAlpha3(String a3) {
  var cu = a3.codeUnits;
  return (cu[0] - baseChar) << 20 | (cu[1] - baseChar) << 15 | (cu[2] - baseChar) << 10;
}

String unpackAlpha3(int i) {
  final _a3Code = <int>[0, 0, 0];
  _a3Code[0] = baseChar + ((i >> 20) & 0x1F);
  _a3Code[1] = baseChar + ((i >> 15) & 0x1F);
  _a3Code[2] = baseChar + ((i >> 10) & 0x1F);
  return String.fromCharCodes(_a3Code);
}

void unpackAlpha3i(int i, List<int> cu) {
  cu[0] = baseChar + ((i >> 20) & 0x1F);
  cu[1] = baseChar + ((i >> 15) & 0x1F);
  cu[2] = baseChar + ((i >> 10) & 0x1F);
}
