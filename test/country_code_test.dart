// Copyright (c) 2019-2021, Denis Portnov. All rights reserved.
// Released under MIT License that can be found in the LICENSE file.

import 'package:country_code/country_code.dart';
import 'package:test/test.dart';

void main() {
  group('ISO-assigned', () {
    // Values are checked against tool/iso3166.tsv in generator_test.dart.
    // Checks below don't need file access and can run on any platform.
    test('Values are consistent', () {
      expect(CountryCode.values, isNotEmpty);
      for (var i = 0; i < CountryCode.values.length; i++) {
        final c = CountryCode.values[i];

        expect(c.index, i);
        expect(c.alpha2, matches(RegExp(r'^[A-Z]{2}$')));
        expect(c.alpha3, matches(RegExp(r'^[A-Z]{3}$')));
        expect(c.numeric, inInclusiveRange(1, 899));
        expect(c.isUserAssigned, isFalse);
      }
    });

    test('Values are statically accessible', () {
      for (final c in CountryCode.values) {
        expect(identical(CountryCode.parse(c.alpha2), c), isTrue);
        expect(identical(CountryCode.parse(c.alpha3), c), isTrue);
        expect(identical(CountryCode.ofAlpha(c.alpha2), c), isTrue);
        expect(identical(CountryCode.ofAlpha(c.alpha3), c), isTrue);
        expect(identical(CountryCode.ofNumeric(c.numeric), c), isTrue);
      }
    });

    test('Can be printed', () {
      expect(CountryCode.RU.toString(), 'CountryCode.RU');
    });
  });

  group('User-assigned', () {
    tearDown(() {
      CountryCode.unassignAll();
    });

    test('Can create user-assigned country code', () {
      final a2 = 'QP';
      final a3 = 'QPX';
      final n = 910;

      final c = CountryCode.user(alpha2: a2, alpha3: a3, numeric: n);

      expect(c.alpha2, a2);
      expect(c.alpha3, a3);
      expect(c.numeric, n);
      expect(c.isUserAssigned, isTrue);

      // not statically accessible
      expect(() => CountryCode.ofAlpha(a2), throwsArgumentError);
    });

    test('Can not create user-assigned country with out of range code', () {
      const codesA2 = <String>['QL', 'ZA'];
      for (final code in codesA2) {
        expect(() => CountryCode.user(alpha2: code), throwsArgumentError);
      }

      const codesA3 = <String>['QLA', 'ZAA'];
      for (final code in codesA3) {
        expect(() => CountryCode.user(alpha3: code), throwsArgumentError);
      }

      const codesN = <int>[0, 899, 1000];
      for (final code in codesN) {
        expect(() => CountryCode.user(numeric: code), throwsArgumentError);
      }
    });

    test('Can not create user-assigned country with malformed code', () {
      expect(() => CountryCode.user(), throwsArgumentError);

      const codesA2 = <String>['', 'Q', 'QPX', 'qp', 'Q1', 'Q@'];
      for (final code in codesA2) {
        expect(() => CountryCode.user(alpha2: code), throwsArgumentError);
        expect(() => CountryCode.assign(alpha2: code), throwsArgumentError);
      }

      const codesA3 = <String>['', 'QP', 'QPXX', 'qpx', 'QP1', 'QP['];
      for (final code in codesA3) {
        expect(() => CountryCode.user(alpha3: code), throwsArgumentError);
        expect(() => CountryCode.assign(alpha3: code), throwsArgumentError);
      }

      expect(() => CountryCode.assign(), throwsArgumentError);
      expect(CountryCode.userValues, isEmpty);
    });

    test('Can be assigned with Alpha-2 only', () {
      final a2 = 'QP';

      final index = CountryCode.assign(alpha2: a2);
      final c = CountryCode.values[index];

      expect(c.alpha2, a2);
      expect(c.alpha3, '');
      expect(c.numeric, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can be assigned with Alpha-3 only', () {
      final a3 = 'XXZ';

      final index = CountryCode.assign(alpha3: a3);
      final c = CountryCode.values[index];

      expect(c.alpha2, '');
      expect(c.alpha3, a3);
      expect(c.numeric, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can be assigned with numeric only', () {
      final n = 999;

      final index = CountryCode.assign(numeric: n);
      final c = CountryCode.values[index];

      expect(c.alpha2, '');
      expect(c.alpha3, '');
      expect(c.numeric, n);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can not assign same user code more than once', () {
      CountryCode.assign(alpha2: 'XA', alpha3: 'XAA', numeric: 900);
      expect(() => CountryCode.assign(alpha2: 'XA'), throwsStateError);
    });

    test('Can be checked for equality', () {
      final c1 = CountryCode.user(alpha2: 'ZZ');
      final c2 = CountryCode.user(alpha2: 'ZZ');

      expect(identical(c1, c2), isFalse);
      expect(c1, equals(c2));
    });

    test('Can be printed', () {
      expect(CountryCode.user(alpha2: 'ZZ').toString(), 'CountryCode.ZZ');
      expect(CountryCode.user(alpha3: 'ZZZ').toString(), 'CountryCode.ZZZ');
      expect(CountryCode.user(numeric: 999).toString(), 'CountryCode.999');
    });
  });
}
