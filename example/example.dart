import 'package:country_code/country_code.dart';

void main() {
  // All ISO country codes are accessible via constants
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

  // Always same value for the same country code is returned
  print(identical(CountryCode.ofAlpha('US'), CountryCode.US)); // -> true

  // You can use CountryCode as map key
  var translations = {
    'en': {
      CountryCode.US: 'United States of America',
    },
    'fr': {
      CountryCode.US: 'États-Unis d\'Amérique',
    },
    'es': {
      CountryCode.US: 'Estados Unidos de América',
    }
  };

  for (var lang in ['en', 'fr', 'es']) {
    print("${CountryCode.US.alpha2}: ${translations[lang]?[CountryCode.US]}");
  }
}
