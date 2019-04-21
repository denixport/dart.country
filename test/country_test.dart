// Copyright (c) 2019, Denis Portnov. All rights reserved.
// Released under MIT License that can be found in the LICENSE file.

import 'package:country/country_code.dart';
import 'package:test/test.dart';
import 'gold.dart';

void main() {
  group('ISO-assigned', () {
    test('Generated values are correct', () {
      var lines = isoGold.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var fields = lines[i].split("\t");
        var c = CountryCode.values[i];

        expect(c.alpha2, fields[0]);
        expect(c.alpha3, fields[1]);
        expect(c.numeric, int.parse(fields[2]));
        expect(c.isUserAssigned, isFalse);
      }
    });

    test('Generated values are statically accesible', () {
      var lines = isoGold.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var fields = lines[i].split("\t");
        var n = int.parse(fields[2]);
        var c = CountryCode.values[i];

        expect(identical(CountryCode.parse(fields[1]), c), isTrue);
        expect(identical(CountryCode.ofAlphaCode(fields[0]), c), isTrue);
        expect(identical(CountryCode.ofAlphaCode(fields[1]), c), isTrue);
        expect(identical(CountryCode.ofNumericCode(n), c), isTrue);
      }
    });

    test('Can be printed', () {
      expect(CountryCode.RU.toString(), "Country.RU");
    });
  });

  group('User-assigned', () {
    tearDown(() {
      CountryCode.unassignAll();
    });

    test('Can create user-assigned country', () {
      String a2 = "QP";
      String a3 = "QPX";
      int n = 910;

      var c = CountryCode.user(alpha2Code: a2, alpha3Code: a3, numericCode: n);

      expect(c.alpha2, a2);
      expect(c.alpha3, a3);
      expect(c.numeric, n);
      expect(c.isUserAssigned, isTrue);

      // not statically accessible
      expect(() => CountryCode.ofAlphaCode(a2), throwsArgumentError);
    });

    test('Can not create user-assigned country with out of range code', () {
      const codesA2 = <String>["QL", "ZA"];
      for (var code in codesA2) {
        expect(() => CountryCode.user(alpha2Code: code), throwsArgumentError);
      }

      const codesA3 = <String>["QLA", "ZAA"];
      for (var code in codesA3) {
        expect(() => CountryCode.user(alpha3Code: code), throwsArgumentError);
      }

      const codesN = <int>[0, 899, 1000];
      for (var code in codesN) {
        expect(() => CountryCode.user(numericCode: code), throwsArgumentError);
      }
    });

    test('Can be assigned with Alpha-2 only', () {
      String a2 = "QP";

      int index = CountryCode.assign(alpha2Code: a2);
      var c = CountryCode.userValues[index];

      expect(c.alpha2, a2);
      expect(c.alpha3, "");
      expect(c.numeric, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can be assigned with Alpha-3 only', () {
      String a3 = "XXZ";

      int index = CountryCode.assign(alpha3Code: a3);
      var c = CountryCode.userValues[index];

      expect(c.alpha2, "");
      expect(c.alpha3, a3);
      expect(c.numeric, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can be assigned with numeric only', () {
      int n = 999;

      int index = CountryCode.assign(numericCode: n);
      var c = CountryCode.userValues[index];

      expect(c.alpha2, "");
      expect(c.alpha3, "");
      expect(c.numeric, n);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can not assign same user code more than once', () {
      CountryCode.assign(alpha2Code: "XA", alpha3Code: "XAA", numericCode: 900);
      expect(() => CountryCode.assign(alpha2Code: "XA"), throwsStateError);
    });

    test('Can be checked for equality', () {
      var c1 = CountryCode.user(alpha2Code: "ZZ");
      var c2 = CountryCode.user(alpha2Code: "ZZ");

      expect(identical(c1, c2), isFalse);
      expect(c1, equals(c2));
    });

    test('Can be printed', () {
      expect(CountryCode.user(alpha2Code: "ZZ").toString(), "Country.ZZ");
      expect(CountryCode.user(alpha3Code: "ZZZ").toString(), "Country.ZZZ");
      expect(CountryCode.user(numericCode: 999).toString(), "Country.999");
    });
  });
}
