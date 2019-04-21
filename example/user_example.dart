import 'package:country/country_code.dart';

void main() {
  CountryCode c1, c2, c3, c4, c5;

  // Create values with custom codes (From ISO defined code range)
  c1 = CountryCode.user(alpha2Code: "AA");
  print(c1.alpha2); // -> AA
  print(c1.alpha3); // -> 
  print(c1.numeric); // -> 0
  
  // Country values for the same code are equal, but not the same object
  c1 = CountryCode.user(alpha3Code: "XAA");
  c2 = CountryCode.user(alpha3Code: "XAA");
  print(c1 == c2); // -> true
  print(identical(c1, c2)); // -> false

  // You need to assign country code using static method assign(), 
  // to be able to use parsing and static accessors for the code.
  int index = CountryCode.assign(alpha3Code: "XAA", numericCode: 901);
  print(index); // -> 0
  print(CountryCode.userValues); // -> [Country.XXA]

  c1 = CountryCode.userValues[index];
  c2 = CountryCode.ofAlphaCode("XAA");
  c3 = CountryCode.ofNumericCode(901);
  c4 = CountryCode.parse("XAA");
  c5 = CountryCode.parse("901");

  print(identical(c1, c2)); // -> true
  print(identical(c2, c3)); // -> true
  print(identical(c3, c4)); // -> true
  print(identical(c4, c5)); // -> true

  // Remove all user-assign codes from the class
  CountryCode.unassignAll();
  print(CountryCode.userValues.length); // -> 0

  // Now you can not parse or get value for the code 'XAA' 
  print(CountryCode.tryParse("XAA")); // - null

}
