//this is a cli example
// ignore_for_file: avoid_print

import 'package:country_code2/country_code2.dart';

void main() {
  // All ISO country codes are accessible via constants
  print(CountryCodes.us.alpha3); // -> USA
  print(CountryCodes.us.numeric); // -> 840
  print(CountryCodes.us.symbol); // -> 🇺🇸
  print(CountryCodes.us.countryName); // -> United States of America

  // The list of ISO-assigned codes are in CountryCode.values
  final list = CountryCode.values.map<String>((c) => c.alpha2).join(', ');
  print(list);

  // You can statically access countries by alpha-2, alpha-3, or numeric code
  // That's also helpful to get other ISO codes for known code
  print(CountryCode.ofAlpha('US').alpha2); // -> US
  print(CountryCode.ofAlpha('USA').alpha2); // -> US
  print(CountryCode.ofNumeric(840).alpha2); // -> US

  // Always same value for the same country code is returned
  print(identical(CountryCode.ofAlpha('US'), CountryCodes.us)); // -> true

  // You can use CountryCode as map key
  final translations = {
    'en': {
      CountryCodes.us: 'United States of America',
    },
    'fr': {
      CountryCodes.us: "États-Unis d'Amérique",
    },
    'es': {
      CountryCodes.us: 'Estados Unidos de América',
    }
  };

  /// or take it's name directly:
  print(CountryCodes.us.countryName);

  for (final lang in ['en', 'fr', 'es']) {
    print('${CountryCodes.us.alpha2}: ${translations[lang]?[CountryCodes.us]}');
  }
}
