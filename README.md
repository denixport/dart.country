List of ISO 3166-1 assigned country codes.

[![pub package](https://img.shields.io/pub/v/country_code.svg)](https://pub.dartlang.org/packages/country_code)
[![Build Status](https://travis-ci.org/denixport/dart.country.svg?branch=master)](https://travis-ci.org/denixport/dart.country)

## Features
* [x] ISO 3166-1 alpha-2. alpha-3, and numeric country codes in enum-like class
* [x] Parsing of country codes from string
* [x] Support for (user-assigned code elements)[https://en.wikipedia.org/wiki/ISO_3166-1#Reserved_and_user-assigned_code_elements]


## Usage

```dart
import 'package:country_code/country_code.dart';

var code = CountryCode.tryParse("US");
if (code == CountryCode.US) {
  print(code.alpha2);
  print(code.alpha3);
  print(code.numeric);
}
```
(See more examples)[https://github.com/denixport/dart.country/tree/master/example]


## Bugs and feature requests

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/denixport/dart.country/issues
