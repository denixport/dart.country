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
        var c = Country.values[i];

        expect(identical(Country.ofAlphaCode(fields[0]), c), isTrue);
        expect(identical(Country.ofAlphaCode(fields[1]), c), isTrue);
        expect(identical(Country.ofNumericCode(int.parse(fields[2])), c), isTrue);
      }
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

  });
}
