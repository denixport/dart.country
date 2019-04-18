// Copyright (c) 2019, Denis Portnov. All rights reserved.
// Released under MIT License that can be found in the LICENSE file.

import 'package:country/country.dart';
import 'package:test/test.dart';
import 'gold.dart';

void main() {
  group('ISO-assigned', () {
    test('Generated values are correct', () {
      var lines = isoGold.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var fields = lines[i].split("\t");
        var c = Country.values[i];

        expect(c.alpha2Code, fields[0]);
        expect(c.alpha3Code, fields[1]);
        expect(c.numericCode, int.parse(fields[2]));
        expect(c.isUserAssigned, isFalse);
      }
    });

    test('Generated values are statically accesible', () {
      var lines = isoGold.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var fields = lines[i].split("\t");
        var n = int.parse(fields[2]);
        var c = Country.values[i];

        expect(identical(Country.parse(fields[1]), c), isTrue);
        expect(identical(Country.ofAlphaCode(fields[0]), c), isTrue);
        expect(identical(Country.ofAlphaCode(fields[1]), c), isTrue);
        expect(identical(Country.ofNumericCode(n), c), isTrue);
      }
    });

    test('Can be printed', () {
      expect(Country.RU.toString(), "Country.RU");
    });
  });

  group('User-assigned', () {
    tearDown(() {
      Country.unassignAll();
    });

    test('Can create user-assigned country', () {
      String a2 = "QP";
      String a3 = "QPX";
      int n = 910;

      var c = Country.user(alpha2Code: a2, alpha3Code: a3, numericCode: n);

      expect(c.alpha2Code, a2);
      expect(c.alpha3Code, a3);
      expect(c.numericCode, n);
      expect(c.isUserAssigned, isTrue);

      // not statically accessible
      expect(() => Country.ofAlphaCode(a2), throwsArgumentError);
    });

    test('Can not create user-assigned country with out of range code', () {
      const codesA2 = <String>["QL", "ZA"];
      for (var code in codesA2) {
        expect(() => Country.user(alpha2Code: code), throwsArgumentError);
      }

      const codesA3 = <String>["QLA", "ZAA"];
      for (var code in codesA3) {
        expect(() => Country.user(alpha3Code: code), throwsArgumentError);
      }

      const codesN = <int>[0, 899, 1000];
      for (var code in codesN) {
        expect(() => Country.user(numericCode: code), throwsArgumentError);
      }
    });

    test('Can be assigned with Alpha-2 only', () {
      String a2 = "QP";

      int index = Country.assign(alpha2Code: a2);
      var c = Country.userValues[index];

      expect(c.alpha2Code, a2);
      expect(c.alpha3Code, "");
      expect(c.numericCode, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can be assigned with Alpha-3 only', () {
      String a3 = "XXZ";

      int index = Country.assign(alpha3Code: a3);
      var c = Country.userValues[index];

      expect(c.alpha2Code, "");
      expect(c.alpha3Code, a3);
      expect(c.numericCode, 0);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can be assigned with numeric only', () {
      int n = 999;

      int index = Country.assign(numericCode: n);
      var c = Country.userValues[index];

      expect(c.alpha2Code, "");
      expect(c.alpha3Code, "");
      expect(c.numericCode, n);
      expect(c.isUserAssigned, isTrue);
    });

    test('Can not assigne country more than once', () {
      Function assf = () =>
          Country.assign(alpha2Code: "AA", alpha3Code: "AAA", numericCode: 900);

      // assign first time
      assf();

      // expect no double assignment
      expect(assf, throwsArgumentError);
    });

    test('Can be checked for equality', () {
      var c1 = Country.user(alpha2Code: "ZZ");
      var c2 = Country.user(alpha2Code: "ZZ");

      expect(identical(c1, c2), isFalse);
      expect(c1, equals(c2));
    });

    test('Can be printed', () {
      expect(Country.user(alpha2Code: "ZZ").toString(), "Country.ZZ");
      expect(Country.user(alpha3Code: "ZZZ").toString(), "Country.ZZZ");
      expect(Country.user(numericCode: 999).toString(), "Country.999");
    });
  });
}
