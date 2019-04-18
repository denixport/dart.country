import 'package:country/country.dart';

void main() {
  Country c1, c2, c3, c4, c5;

  // Create values with custom codes (From ISO defined code range)
  c1 = Country.user(alpha2Code: "AA");
  print(c1.alpha2Code); // -> AA
  print(c1.alpha3Code); // -> 
  print(c1.numericCode); // -> 0
  
  // Country values for the same code are equal, but not the same object
  c1 = Country.user(alpha3Code: "XAA");
  c2 = Country.user(alpha3Code: "XAA");
  print(c1 == c2); // -> true
  print(identical(c1, c2)); // -> false

  // You need to assign country code using static method assign(), 
  // to be able to use parsing and static accessors for the code.
  int index = Country.assign(alpha3Code: "XAA", numericCode: 901);
  print(index); // -> 0
  print(Country.userValues); // -> [Country.XXA]

  c1 = Country.userValues[index];
  c2 = Country.ofAlphaCode("XAA");
  c3 = Country.ofNumericCode(901);
  c4 = Country.parse("XAA");
  c5 = Country.parse("901");

  print(identical(c1, c2)); // -> true
  print(identical(c2, c3)); // -> true
  print(identical(c3, c4)); // -> true
  print(identical(c4, c5)); // -> true

  // Remove all user-assign codes from the class
  Country.unassignAll();
  print(Country.userValues.length); // -> 0

  // Now you can not parse or get value for the code 'XAA' 
  print(Country.tryParse("XAA")); // - null

}
