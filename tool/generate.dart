// Copyright (c) 2026, Denis Portnov. All rights reserved.
// Released under MIT License that can be found in the LICENSE file.

/// Generates ISO 3166-1 constants of `CountryCode` from `tool/iso3166.tsv`.
///
/// Rewrites the part of `lib/src/country_code.dart` between
/// `//GENERATED:START` and `//GENERATED:END` markers.
///
/// Usage (from the package root):
///
///     dart run tool/generate.dart          # regenerate
///     dart run tool/generate.dart --check  # exit 1 if file is out of date
library;

import 'dart:io';

const dataPath = 'tool/iso3166.tsv';
const targetPath = 'lib/src/country_code.dart';

const _startMarker = '  //GENERATED:START\n';
const _endMarker = '  //GENERATED:END\n';
const _valuesPerLine = 18;

void main(List<String> args) {
  final check = args.contains('--check');
  final source = File(targetPath).readAsStringSync();
  final countries = parseData(File(dataPath).readAsStringSync());
  final generated = splice(source, generateBlock(countries));

  if (generated == source) {
    stdout.writeln('$targetPath is up to date.');
    return;
  }
  if (check) {
    stderr.writeln(
      '$targetPath is out of date, run: dart run tool/generate.dart',
    );
    exitCode = 1;
    return;
  }
  File(targetPath).writeAsStringSync(generated);
  stdout.writeln('Generated ${countries.length} country codes in $targetPath.');
}

/// ISO 3166-1 country entry.
class IsoCountry {
  final String alpha2;
  final String alpha3;
  final int numeric;
  final String name;

  const IsoCountry(this.alpha2, this.alpha3, this.numeric, this.name);

  /// Packs codes the same way as `CountryCode` does (see its `_code` field).
  int get packed {
    const base = 0x41 - 1; // 'A' - 1
    final a2 = alpha2.codeUnits;
    final a3 = alpha3.codeUnits;
    return (a2[0] - base) << 30 |
        (a2[1] - base) << 25 |
        (a3[0] - base) << 20 |
        (a3[1] - base) << 15 |
        (a3[2] - base) << 10 |
        numeric;
  }
}

final _alpha2 = RegExp(r'^[A-Z]{2}$');
final _alpha3 = RegExp(r'^[A-Z]{3}$');
final _numeric = RegExp(r'^[0-9]{1,3}$');

/// Parses and validates data file contents.
///
/// Lines starting with `#` and blank lines are ignored.
/// Throws [FormatException] on malformed, duplicate, or unsorted entries.
List<IsoCountry> parseData(String data) {
  final countries = <IsoCountry>[];
  final seen = <Object>{};
  final lines = data.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trimRight();
    if (line.isEmpty || line.startsWith('#')) continue;

    Never fail(String message) =>
        throw FormatException('$dataPath:${i + 1}: $message', line);

    final fields = line.split('\t');
    if (fields.length != 4) fail('expected 4 tab-separated fields');
    final [alpha2, alpha3, numericStr, name] = fields;

    if (!_alpha2.hasMatch(alpha2)) fail('invalid alpha-2 code "$alpha2"');
    if (!_alpha3.hasMatch(alpha3)) fail('invalid alpha-3 code "$alpha3"');
    if (!_numeric.hasMatch(numericStr)) fail('invalid numeric "$numericStr"');
    final numeric = int.parse(numericStr);
    // 900..999 is reserved for user-assigned codes
    if (numeric < 1 || numeric > 899) fail('numeric $numeric out of range');
    if (name.trim().isEmpty) fail('empty name');

    for (final code in [alpha2, alpha3, numeric]) {
      if (!seen.add(code)) fail('duplicate code "$code"');
    }
    // order defines CountryCode.index, keep it deterministic
    if (countries.isNotEmpty && countries.last.alpha2.compareTo(alpha2) > 0) {
      fail('entries must be sorted by alpha-2 code');
    }

    countries.add(IsoCountry(alpha2, alpha3, numeric, name.trim()));
  }

  if (countries.isEmpty) {
    throw const FormatException('$dataPath: no entries found');
  }
  return countries;
}

/// Generates the class members placed between the markers.
String generateBlock(List<IsoCountry> countries) {
  final out = StringBuffer();
  for (final c in countries) {
    out
      ..writeln('  /// ${c.name} ${c.alpha2} ${c.alpha3} ${c.numeric}')
      ..writeln('  static const ${c.alpha2} = CountryCode._(${c.packed});')
      ..writeln();
  }

  out
    ..writeln('  // List of ISO standard values')
    ..writeln('  static const _values = <CountryCode>[');
  for (var i = 0; i < countries.length; i += _valuesPerLine) {
    final codes = countries.skip(i).take(_valuesPerLine).map((c) => c.alpha2);
    // trailing `//` on the first line keeps the formatter from
    // putting one value per line
    out.writeln('    ${codes.join(', ')},${i == 0 ? ' //' : ''}');
  }
  out.writeln('  ];');

  return out.toString();
}

/// Replaces contents between generated-code markers in [source].
String splice(String source, String block) {
  final start = source.indexOf(_startMarker);
  final end = source.indexOf(_endMarker);
  if (start == -1 || end == -1 || end < start) {
    throw StateError('$targetPath: generated-code markers not found');
  }
  return source.replaceRange(start + _startMarker.length, end, block);
}
