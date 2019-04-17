import 'package:country/country.dart';
import 'package:test/test.dart';
import 'gold.dart';

void main() {
  group('ISO-assigned', () {
    test('Generated constants are correct', () {
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
  }); 

}
