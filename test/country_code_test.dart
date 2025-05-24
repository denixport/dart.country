// test/country_code_test.dart

import 'dart:io';

import 'package:country_code2/country_code2.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  // Load and parse the YAML once for all tests
  final yamlContent = File('tool/country_codes.yaml').readAsStringSync();
  final doc = loadYaml(yamlContent) as YamlMap;

  // 'data' is now a Map<String, Map>, not a List
  final dataMap = doc['data'] as YamlMap;
  final isoData = dataMap.entries.map((entry) {
    final fields = entry.value as YamlMap;
    return <String>[
      fields['alpha2'] as String,
      fields['alpha3'] as String,
      '${fields['numeric']}',
    ];
  }).toList();

  group('ISO-assigned', () {
    test('Generated values are correct', () {
      for (var i = 0; i < isoData.length; i++) {
        final fields = isoData[i];
        final c = CountryCode.values[i];

        expect(c.alpha2, equals(fields[0]));
        expect(c.alpha3, equals(fields[1]));
        expect(c.numeric, equals(int.parse(fields[2])));
        expect(c.isUserAssigned, isFalse);
        expect(identical(CountryCode.values[c.index], c), isTrue);
      }
    });

    test('Generated values are statically accessible', () {
      for (var i = 0; i < isoData.length; i++) {
        final fields = isoData[i];
        final n = int.parse(fields[2]);
        final c = CountryCode.values[i];

        expect(identical(CountryCode.parse(fields[1]), c), isTrue);
        expect(identical(CountryCode.ofAlpha(fields[0]), c), isTrue);
        expect(identical(CountryCode.ofAlpha(fields[1]), c), isTrue);
        expect(identical(CountryCode.ofNumeric(n), c), isTrue);
      }
    });

    test('Can be printed', () {
      // Now referencing your generated CountryCodes class
      expect(CountryCodes.ru.toString(), 'CountryCode.RU');
      expect(CountryCodes.au.countryName, 'Australia');
    });
  });

  group('User-assigned', () {
    tearDown(CountryCode.unassignAll);

    test('Can create user-assigned country code', () {
      const a2 = 'QP';
      const a3 = 'QPX';
      const n = 910;
      final c = CountryCode.user(
        alpha2: a2,
        alpha3: a3,
        numeric: n,
        countryName: 'Custom',
      );

      expect(c.alpha2, a2);
      expect(c.alpha3, a3);
      expect(c.numeric, n);
      expect(c.countryName, 'Custom');
      expect(c.isUserAssigned, isTrue);
      expect(() => CountryCode.ofAlpha(a2), throwsArgumentError);
    });

    test('Cannot create out-of-range user country', () {
      for (final code in ['QL', 'ZA']) {
        expect(() => CountryCode.user(alpha2: code), throwsArgumentError);
      }
      for (final code in ['QLA', 'ZAA']) {
        expect(() => CountryCode.user(alpha3: code), throwsArgumentError);
      }
      for (final code in [0, 899, 1000]) {
        expect(() => CountryCode.user(numeric: code), throwsArgumentError);
      }
    });

    test('Assign with only Alpha-2', () {
      final idx = CountryCode.assign(alpha2: 'QP');
      final c = CountryCode.values[idx];
      expect(c.alpha2, 'QP');
      expect(c.alpha3, '');
      expect(c.numeric, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Assign with only Alpha-3', () {
      final idx = CountryCode.assign(alpha3: 'XXZ');
      final c = CountryCode.values[idx];
      expect(c.alpha2, '');
      expect(c.alpha3, 'XXZ');
      expect(c.numeric, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Assign with only numeric', () {
      final idx = CountryCode.assign(numeric: 999);
      final c = CountryCode.values[idx];
      expect(c.alpha2, '');
      expect(c.alpha3, '');
      expect(c.numeric, 999);
      expect(c.isUserAssigned, isTrue);
    });

    test('No duplicate user code', () {
      CountryCode.assign(alpha2: 'XA', alpha3: 'XAA', numeric: 900);
      expect(() => CountryCode.assign(alpha2: 'XA'), throwsStateError);
    });

    test('Equality works', () {
      final c1 = CountryCode.user(alpha2: 'ZZ');
      final c2 = CountryCode.user(alpha2: 'ZZ');
      expect(identical(c1, c2), isFalse);
      expect(c1, equals(c2));
    });

    test('User codes can be printed', () {
      expect(CountryCode.user(alpha2: 'ZZ').toString(), 'CountryCode.ZZ');
      expect(CountryCode.user(alpha3: 'ZZZ').toString(), 'CountryCode.ZZZ');
      expect(CountryCode.user(numeric: 999).toString(), 'CountryCode.999');
    });
  });
}
