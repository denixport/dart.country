import 'package:country/country_code.dart';

void main() {
  // All ISO country codes are accesible via constants
  print(CountryCode.US.alpha3); // -> USA
  print(CountryCode.US.numeric); // -> 840
  print(CountryCode.US.symbol); // -> 🇺🇸

  // The list of countries with ISO-assigned codes are in Country.values
  var list = CountryCode.values.map<String>((CountryCode c) => c.alpha2).join(", ");
  print(list);

  // You can statically access countries by alpha-2, alpha-3, or numeric code
  // That's also helpful to get other ISO codes for known code
  print(CountryCode.ofAlphaCode("US").alpha2); // -> US
  print(CountryCode.ofAlphaCode("USA").alpha2); // -> US
  print(CountryCode.ofNumericCode(840).alpha2); // -> US

  // Always same country value is returned
  print(identical(CountryCode.ofAlphaCode("US"), CountryCode.US)); // -> true

  // You can also parse alpha-2, alpha-3, or numeric code
  print(CountryCode.parse("US").alpha2); // -> US
  print(CountryCode.parse("USA").alpha2); // -> US
  print(CountryCode.parse("840").alpha2); // -> US
}
