import 'package:country/country.dart';

void main() {
  // All ISO country codes are accesible via constants
  print(Country.US.alpha3Code); // -> USA
  print(Country.US.numericCode); // -> 840

  // The list of countries with ISO-assigned codes are in Country.values
  var list = Country.values.map<String>((Country c) => c.alpha2Code).join(", ");
  print(list);

  // You can statically access countries by alpha-2, alpha-3, or numeric code
  // That's also helpful to get other ISO codes for known code
  print(Country.ofAlphaCode("US").alpha2Code); // -> US
  print(Country.ofAlphaCode("USA").alpha2Code); // -> US
  print(Country.ofNumericCode(840).alpha2Code); // -> US

  // Always same country value is returned
  print(identical(Country.ofAlphaCode("US"), Country.US)); // -> true

  // You can also parse alpha-2, alpha-3, or numeric code
  print(Country.parse("US").alpha2Code); // -> US
  print(Country.parse("USA").alpha2Code); // -> US
  print(Country.parse("840").alpha2Code); // -> US
}
