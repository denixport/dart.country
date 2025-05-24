// Copyright (c) 2024, Denis Portnov. All rights reserved.
// Released under MIT License that can be found in the LICENSE file.

import 'package:meta/meta.dart';

part 'country_codes.g.dart';

@immutable
class CountryCode {
  const CountryCode._(this._code, this.countryName);

  /// Creates user-defined country code.
  /// Note: Code is not registered in class `values`, use `assign` to
  /// register user country codes.
  factory CountryCode.user(
      {String? countryName,
      String? alpha2,
      String? alpha3,
      int? numeric}) {
    assert(!(alpha2 == null && alpha3 == null && numeric == null),
        'at least one must be passed');
    assert(alpha2 == null || alpha2.length >= 2,
        'If alpha2 is passed it must be at least 2 characters long');
    assert(alpha3 == null || alpha3.length >= 3,
        'If alpha3 is passed it must be at least 3 characters long');

    var a2 = 0;
    if (alpha2 != null) {
      a2 = _packAlpha2(alpha2.codeUnits);
      if (!_isInRange(a2, _userA2Ranges)) {
        throw ArgumentError('Alpha-2 code is not in allowed range');
      }
    }

    var a3 = 0;
    if (alpha3 != null) {
      a3 = _packAlpha3(alpha3.codeUnits);
      if (!_isInRange(a3, _userA3Ranges)) {
        throw ArgumentError('Alpha-3 code is not in allowed range');
      }
    }

    if (numeric != null && (numeric < 900 || numeric > 999)) {
      throw ArgumentError.value(
          numeric, 'numeric', 'Should be between 900..999');
    }

    numeric ??= 0;

    // hack to avoid 32-bit truncating in JS
    // ignore: literal_only_boolean_expressions
    if ((1 << 32) == 0) {
      return CountryCode._(a2 + (a3 | numeric), countryName);
    }

    return CountryCode._(a2 | a3 | numeric, countryName);
  }
  // 'A' - 1
  static const _baseChar = 0x41 - 1;

  // code units buffer for alpha codes
  static final _a2cu = <int>[0, 0];
  static final _a3cu = <int>[0, 0, 0];

  // Country alphanumeric codes are packed into 35-bit unsigned integer
  // [0-9] Alpha-2 code, 5 bits per character
  // [10-24] Alpha-3 code, 5 bits per character
  // [25-35] int representing numeric code 0-999
  final int _code;

  /// The name of the country
  final String? countryName;

  /// Alpha-2 code as defined in (ISO 3166-1)[https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2]
  /// Returns empty string for user-assigned values that doesn't
  /// have alpha-2 code
  String get alpha2 {
    _unpackAlpha2(_code);
    return (_a2cu[0] != _baseChar) ? String.fromCharCodes(_a2cu) : '';
  }

  /// Alpha-3 code as defined in (ISO 3166-1)[https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3]
  /// Returns empty string for user-assigned values that doesn't
  /// have alpha-3 code
  String get alpha3 {
    _unpackAlpha3(_code);
    return (_a3cu[0] != _baseChar) ? String.fromCharCodes(_a3cu) : '';
  }

  /// Numeric code as defined in (ISO 3166-1)[https://en.wikipedia.org/wiki/ISO_3166-1_numeric]
  /// Returns 0 for user-assigned values that doesn't have alpha-3 code
  int get numeric => _code & 0x3ff;

  /// Returns unicode symbol for country code
  String get symbol {
    const base = 0x1f1a5;
    if (_code & 0x3ff != 0) {
      _unpackAlpha2(_code);
      return String.fromCharCodes(<int>[base + _a2cu[0], base + _a2cu[1]]);
    }
    return '';
  }

  /// Returns `true` if the code is official ISO-assigned
  bool get isOfficial {
    final n = _code & 0x3ff;
    return n > 0 && n < 900;
  }

  /// Returns `true` if the code is user-assigned.
  /// See (User-assigned code elements)[https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#User-assigned_code_elements]
  bool get isUserAssigned {
    final n = _code & 0x3ff;
    return n == 0 || n >= 900;
  }

  /// Returns position of the value in list of all country codes.
  int get index => values.indexOf(this);

  @override
  int get hashCode => _code;

  @override
  bool operator ==(Object other) =>
      other is CountryCode && _code == other._code;

  /// Returns string representation of `CountryCode`.
  /// Which is `CountryCode.` followed by either alpha-2, alpha-2, or numeric
  /// code depending on which code is defined.
  /// For ISO-assigned country codes it always returns `CountryCode.` + alpha-2.
  @override
  String toString() {
    // 'Country'.codeUnits + 3
    const cu = <int>[67, 111, 117, 110, 116, 114, 121, 67, 111, 100, 101, 46];

    _unpackAlpha2(_code);
    if (_a2cu[0] != _baseChar) {
      return String.fromCharCodes(cu + _a2cu);
    }

    _unpackAlpha3(_code);
    if (_a3cu[0] != _baseChar) {
      return String.fromCharCodes(cu + _a3cu);
    }

    final n = _code & 0x3ff;
    if (n != 0) {
      return String.fromCharCodes(cu + n.toString().padLeft(3, '0').codeUnits);
    }

    assert(true, 'Unreachable return');
    return 'Country.UNKNOWN';
  }

  /// List of all ISO-assigned country codes
  /// including any user defined codes assigned via
  /// [CountryCode.user]
  static List<CountryCode> get values {
    if (_userValues.isNotEmpty) {
      return List<CountryCode>.unmodifiable(CountryCodes._values + _userValues);
    }

    return List<CountryCode>.unmodifiable(CountryCodes._values);
  }

  /// List of all user-assigned country codes
  static List<CountryCode> get userValues => List.unmodifiable(_userValues);

  /// Returns country by Alpha-2 or Alpha-3 code
  /// Throws `ArgumentError` if the [code] is invalid or there is no
  /// ISO- or user-assigned country for this [code]
  static CountryCode ofAlpha(String code) {
    int index;

    if (_userValues.isNotEmpty) {
      index = _parseAlpha(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    index = _parseAlpha(code, CountryCodes._values);
    if (index != -1) {
      return CountryCodes._values[index];
    }

    throw ArgumentError('Alpha code "$code" is not assigned');
  }

  /// Returns country code by numeric code
  /// Throws `ArgumentError` if the numeric [code] is invalid or there is no
  /// ISO- or user-assigned country for this [code]
  static CountryCode ofNumeric(int code) {
    int index;
    if (_userValues.isNotEmpty) {
      index = _indexOfNum(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    index = _indexOfNum(code, CountryCodes._values);
    if (index != -1) {
      return CountryCodes._values[index];
    }

    throw ArgumentError('No country assigned for numeric code "$code"');
  }

  // returns index of numeric code in values list
  static int _indexOfNum(int code, List<CountryCode> values) {
    for (var i = 0; i < values.length; i++) {
      if (values[i]._code & 0x3ff == code) {
        return i;
      }
    }
    return -1;
  }

  /// Parses [source] as Alpha-2, alpha-3 or numeric country code
  /// The [source] must be either 2-3 ASCII uppercase letters of alpha code,
  /// or 2-3 digits of numeric code
  /// Throws `FormatException` if the code is not valid country code
  static CountryCode parse(String source) {
    final c = _parse(source);
    if (c == null) {
      throw FormatException('Invalid or non-assigned code', source);
    }
    return c;
  }

  /// Parses [source] as Alpha-2, alpha-3 or numeric country code.
  /// Same as [parse] but returns `null` in case of invalid country code
  static CountryCode? tryParse(String source) => _parse(source);

  //
  static CountryCode? _parse(String code) {
    int index;

    // first try user-assigned alpha code
    if (_userValues.isNotEmpty) {
      index = _parseAlpha(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    // try ISO alpha code
    index = _parseAlpha(code, CountryCodes._values);
    if (index != -1) {
      return CountryCodes._values[index];
    }

    // try user numeric code
    if (_userValues.isNotEmpty) {
      index = _parseNum(code, _userValues);
      if (index != -1) {
        return _userValues[index];
      }
    }

    // try ISO numeric code
    index = _parseNum(code, CountryCodes._values);
    if (index != -1) {
      return CountryCodes._values[index];
    }

    return null;
  }

  // Parses alpha-2 or alpha-3 code, returns -1 for invalid or unassigned
  static int _parseAlpha(String code, List<CountryCode> values) {
    final cu = code.codeUnits;
    switch (cu.length) {
      case 2:
        for (var i = 0; i < values.length; i++) {
          _unpackAlpha2(values[i]._code);
          if (_a2cu[0] == cu[0] && _a2cu[1] == cu[1]) {
            return i;
          }
        }
      case 3:
        for (var i = 0; i < values.length; i++) {
          _unpackAlpha3(values[i]._code);
          if (_a3cu[0] == cu[0] && _a3cu[1] == cu[1] && _a3cu[2] == cu[2]) {
            return i;
          }
        }
    }
    return -1;
  }

  // Parses numeric code, returns -1 for invalid or unassigned
  static int _parseNum(String code, List<CountryCode> values) {
    final n = int.tryParse(code);
    if (n == null) {
      return -1;
    }
    for (var i = 0; i < values.length; i++) {
      if (values[i]._code & 0x3ff == n) {
        return i;
      }
    }
    return -1;
  }

  /// Assigns user-defined codes. Returns index of country value in [userValues]
  /// Codes could be any combination of Alpha-2, alpha-2, or numeric code.
  /// Either one of 3 codes is required.
  /// After calling [assign] user-assigned codes are available through
  /// [parse], [tryParse], [ofAlpha], and [ofNumeric] static methods.
  static int assign(
      { String? countryName,
      String? alpha2,
      String? alpha3,
      int? numeric}) {
    assert(!(alpha2 == null && alpha3 == null && numeric == null),
        'one of the three codes are required');

    // check Alpha-2
    if (alpha2 != null &&
        (_parseAlpha(alpha2, _userValues) != -1 ||
            _parseAlpha(alpha2, CountryCodes._values) != -1)) {
      throw StateError('Alpha-2 code "$alpha2" is already assigned');
    }

    // check Alpha-3
    if (alpha3 != null &&
        (_parseAlpha(alpha3, _userValues) != -1 ||
            _parseAlpha(alpha3, CountryCodes._values) != -1)) {
      throw StateError('Alpha-3 code "$alpha3" is already assigned');
    }

    // check numeric
    if (numeric != null &&
        (_indexOfNum(numeric, _userValues) != -1 ||
            _indexOfNum(numeric, CountryCodes._values) != -1)) {
      throw StateError('Numeric code "$numeric" is already assigned');
    }

    _userValues.add(CountryCode.user(
        alpha2: alpha2,
        alpha3: alpha3,
        numeric: numeric,
        countryName: countryName));

    return CountryCodes._values.length + _userValues.length - 1;
  }

  /// Removes all of user-assigned codes
  static void unassignAll() {
    _userValues.clear();
  }

  // pack/unpack routines ------------------------------------------------------

  static int _packAlpha2(List<int> cu) {
    // hack to avoid 32-bit truncating in JS
    // ignore: literal_only_boolean_expressions
    if ((1 << 32) != 0) {
      return (cu[0] - _baseChar) << 30 | (cu[1] - _baseChar) << 25;
    } else {
      return ((cu[0] - _baseChar) * 0x40000000) + ((cu[1] - _baseChar) << 25);
    }
  }

  // gets Alpha-2 code units from int
  static void _unpackAlpha2(int i) {
    // hack to avoid 32-bit truncating in JS
    // ignore: literal_only_boolean_expressions
    if ((1 << 32) != 0) {
      _a2cu[0] = _baseChar + (i >> 30);
    } else {
      _a2cu[0] = _baseChar + (i ~/ 0x40000000);
    }
    _a2cu[1] = _baseChar + ((i >> 25) & 0x1F);
  }

  static int _packAlpha3(List<int> cu) =>
      (cu[0] - _baseChar) << 20 |
      (cu[1] - _baseChar) << 15 |
      (cu[2] - _baseChar) << 10;

  // gets Alpha-3 code units from int
  static void _unpackAlpha3(int i) {
    _a3cu[0] = _baseChar + ((i >> 20) & 0x1F);
    _a3cu[1] = _baseChar + ((i >> 15) & 0x1F);
    _a3cu[2] = _baseChar + ((i >> 10) & 0x1F);
  }

  static bool _isInRange(int code, List<int> ranges) {
    for (var i = 0; i < ranges.length - 1; i += 2) {
      if (code >= ranges[i] && code <= ranges[i + 1]) {
        return true;
      }
    }
    return false;
  }

  // ranges of user-assignable Alpha-2 codes
  static const _userA2Ranges = <int>[
    1107296256, 1107296256, // AA..AA
    18689818624, 19126026240, // QM..QZ
    25803358208, 26642219008, // XA..XZ
    28789702656, 28789702656, // ZZ..ZZ
  ];

  // ranges of user-assignable Alpha-3 codes
  static const _userA3Ranges = <int>[
    1082368, 1107968, // AAA..AAZ
    18252800, 18704384, // QMA..QZZ
    25199616, 26044416, // XAA..XZZ
    28115968, 28141568, // ZZA..ZZZ
  ];

  // User-assigned countries
  static final _userValues = <CountryCode>[];
}
