List of ISO 3166-1 assigned country codes.

[![pub package](https://img.shields.io/pub/v/country_code.svg)](https://pub.dev/packages/country_code)
![License](https://img.shields.io/github/license/denixport/dart.country.svg)

## Features
* [x] ISO 3166-1 alpha-2. alpha-3, and numeric country codes in enum-like class
* [x] Parsing of country codes from string
* [x] Support for [user-assigned code elements](https://en.wikipedia.org/wiki/ISO_3166-1#Reserved_and_user-assigned_code_elements)


## Usage

```dart
import 'package:country_code/country_code.dart';

// All ISO country codes are accessible as constants
print(CountryCode.US.alpha3); // USA

final code = CountryCode.tryParse('US');
if (code != null) {
  print(code.alpha2); // US
  print(code.alpha3); // USA
  print(code.numeric); // 840
}
```
[See more examples][examples]

## Updating country codes

The ISO 3166-1 constants in `lib/src/country_code.dart` are generated from
`tool/iso3166.tsv`. Only the code between the `//GENERATED:START` and
`//GENERATED:END` markers is generated; the rest of the file is written by hand.

To add, change, or remove a country, edit `tool/iso3166.tsv` (rows are
tab-separated: alpha-2, alpha-3, numeric, English short name, sorted by
alpha-2 code) and regenerate:

```sh
dart run tool/generate.dart
```

`dart run tool/generate.dart --check` exits with an error if the generated code
is out of date; the test suite runs the same check.

## Bugs and feature requests

Please file feature requests and bugs at the [issue tracker][tracker].

[examples]: https://github.com/denixport/dart.country/tree/master/example
[tracker]: https://github.com/denixport/dart.country/issues
