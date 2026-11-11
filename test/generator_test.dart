// Copyright (c) 2026, Denis Portnov. All rights reserved.
// Released under MIT License that can be found in the LICENSE file.

@TestOn('vm')
library;

import 'dart:io';

import 'package:country_code/country_code.dart';
import 'package:test/test.dart';

import '../tool/generate.dart';

void main() {
  final countries = parseData(File(dataPath).readAsStringSync());

  test('Generated code is up to date with $dataPath', () {
    final source = File(targetPath).readAsStringSync();
    expect(
      splice(source, generateBlock(countries)),
      source,
      reason: 'Run: dart run tool/generate.dart',
    );
  });

  test('Values match $dataPath', () {
    expect(CountryCode.values, hasLength(countries.length));
    for (var i = 0; i < countries.length; i++) {
      final c = CountryCode.values[i];
      expect(c.alpha2, countries[i].alpha2);
      expect(c.alpha3, countries[i].alpha3);
      expect(c.numeric, countries[i].numeric);
    }
  });

  group('Data validation', () {
    const ad = 'AD\tAND\t20\tAndorra';

    test('Accepts comments and blank lines', () {
      final parsed = parseData('# comment\n\n$ad\n');
      expect(parsed.single.name, 'Andorra');
      expect(parsed.single.packed, 1209470996);
    });

    for (final (reason, data) in [
      ('no entries', '# only comment\n'),
      ('missing field', 'AD\tAND\t20'),
      ('lowercase alpha-2', 'ad\tAND\t20\tAndorra'),
      ('short alpha-3', 'AD\tAN\t20\tAndorra'),
      ('non-numeric', 'AD\tAND\tX\tAndorra'),
      ('user-assigned numeric', 'AD\tAND\t900\tAndorra'),
      ('empty name', 'AD\tAND\t20\t '),
      ('duplicate alpha-2', '$ad\nAD\tAAA\t21\tAndorra 2'),
      ('duplicate numeric', '$ad\nAE\tARE\t20\tEmirates'),
      ('unsorted', 'AE\tARE\t784\tEmirates\n$ad'),
    ]) {
      test('Rejects $reason', () {
        expect(() => parseData(data), throwsFormatException);
      });
    }
  });
}
