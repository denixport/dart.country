List of ISO 3166-1 assigned country codes.

[![pub package](https://img.shields.io/pub/v/country_code.svg)](https://pub.dartlang.org/packages/country_code)
![License](https://img.shields.io/github/license/denixport/dart.country.svg)

## Features
* [x] ISO 3166-1 alpha-2. alpha-3, and numeric country codes in enum-like class
* [x] Parsing of country codes from string
* [x] Support for [user-assigned code elements](https://en.wikipedia.org/wiki/ISO_3166-1#Reserved_and_user-assigned_code_elements)


## Usage

```dart
import 'package:country_code/country_code.dart';

var code = CountryCode.tryParse("US");
if (code == CountryCodes.us) {
  print(code.countryName);
  print(code.alpha2);
  print(code.alpha3);
  print(code.numeric);
}

/// Use one of the named country codes.
var code = CountryCodes.us;
print(code.countryName);
print(code.alpha2);
print(code.alpha3);
print(code.numeric);

/// Get a full list of Country Codes:
final allCodes = CountryCode.values;
```



## Bugs and feature requests

Please file feature requests and bugs at the [issue tracker][tracker].

[examples]: https://github.com/denixport/dart.country/tree/master/example
[tracker]: https://github.com/denixport/dart.country/issues


# building
The list of country codes are stored in a tool/country_codes.yaml.

You can regenerate the 'country_codes.dart' file by running:
```bash
dart tool/generate_country_codes.dart
```

# Thanks
This code is a fork of  denixport/dart.country