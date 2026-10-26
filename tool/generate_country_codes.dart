// tool/generate_country_codes.dart

import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  // 1) Load the YAML as a mapping: name -> {varName?, alpha2, alpha3, numeric}
  final yamlFile = File('tool/country_codes.yaml');
  final yamlContent = yamlFile.readAsStringSync();
  final doc = loadYaml(yamlContent) as YamlMap;
  final data = doc['data'] as YamlMap;

  // 2) Prepare the output buffer
  final partBuffer = StringBuffer()
    ..writeln('// GENERATED — DO NOT EDIT')
    ..writeln(
        '// ignore_for_file: prefer_single_quotes, lines_longer_than_80_chars')
    ..writeln("part of 'country_code.dart';")
    ..writeln()
    ..writeln('/// ISO country constants + values list')
    ..writeln('class CountryCodes {')
    ..writeln();

  // We'll collect all varNames for the _values list
  final varNames = <String>[];

  // 3) Emit each CountryCode.<varName> in insertion order
  for (final entry in data.entries) {
    final countryName = entry.key as String;
    final m = entry.value as YamlMap;

    final alpha2 = m['alpha2'] as String;
    final alpha3 = m['alpha3'] as String;
    final numeric = m['numeric'] as int;

    // optional override in YAML
    final varName = (m['varName'] as String?) ?? alpha2.toLowerCase();
    varNames.add(varName);

    final packed = _pack(alpha2, alpha3, numeric);

    partBuffer
      ..writeln('  /// $countryName   ($alpha2, $alpha3, $numeric)')
      ..write('  static const $varName = CountryCode._(')
      ..write('$packed,')
      ..write('"$countryName"')
      ..write(');')
      ..writeln()
      ..writeln();
  }

  // 4) Emit the _values table in the same style as before
  partBuffer
    ..writeln('  /// List of ISO standard values')
    ..writeln('  static const _values = <CountryCode>[');

  // To keep lines <80 chars, chunk them (e.g. 8 per line)
  const chunkSize = 8;
  for (var i = 0; i < varNames.length; i += chunkSize) {
    final chunk = varNames.sublist(
      i,
      (i + chunkSize) > varNames.length ? varNames.length : i + chunkSize,
    );
    partBuffer.writeln('    ${chunk.join(', ')},');
  }

  partBuffer
    ..writeln('  ];')
    ..writeln('}');

  // 5) Write the generated part file
  File('lib/src/country_codes.g.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(partBuffer.toString());

  /// It's CLI script.
  // ignore: avoid_print
  print('→ Generated lib/src/country_code.g.dart');
}

/// Packs alpha2, alpha3 and numeric exactly like CountryCode._ does
int _pack(String alpha2, String alpha3, int numeric) {
  const baseChar = 0x41 - 1; // 'A' - 1
  var a2 = 0;
  if (alpha2.length == 2) {
    final cu = alpha2.codeUnits;
    a2 = ((cu[0] - baseChar) << 30) | ((cu[1] - baseChar) << 25);
  }
  var a3 = 0;
  if (alpha3.length == 3) {
    final cu = alpha3.codeUnits;
    a3 = ((cu[0] - baseChar) << 20) |
        ((cu[1] - baseChar) << 15) |
        ((cu[2] - baseChar) << 10);
  }
  return a2 | a3 | numeric;
}
