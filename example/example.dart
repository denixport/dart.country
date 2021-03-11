import 'package:country_code/country_code.dart';

void main() {
  // All ISO country codes are accesible via constants
  print(CountryCode.US.alpha3); // -> USA
  print(CountryCode.US.numeric); // -> 840
  print(CountryCode.US.symbol); // -> 🇺🇸

  // The list of ISO-assigned codes are in CountryCode.values
  var list = CountryCode.values.map<String>((c) => c.alpha2).join(', ');
  print(list);

  // You can statically access countries by alpha-2, alpha-3, or numeric code
  // That's also helpful to get other ISO codes for known code
  print(CountryCode.ofAlpha('US').alpha2); // -> US
  print(CountryCode.ofAlpha('USA').alpha2); // -> US
  print(CountryCode.ofNumeric(840).alpha2); // -> US

  // Always same values for the same country code is returned
  print(identical(CountryCode.ofAlpha('US'), CountryCode.US)); // -> true

  // You can also parse alpha-2, alpha-3, or numeric code
  print(CountryCode.parse('US').alpha2); // -> US
  print(CountryCode.parse('USA').alpha2); // -> US
  print(CountryCode.parse('840').alpha2); // -> US
}
