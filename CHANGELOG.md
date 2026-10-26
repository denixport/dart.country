# 2.0.1
- Validate user-assigned country codes at runtime as exact uppercase ASCII alpha codes or numeric values in the reserved range.
- Reject signed and overlong numeric inputs; reject numeric zero when a user-assigned code has no numeric element.
- Reject `@@` or `@@@` lookups for user-assigned codes with missing alpha elements.
- Avoid allocating a code-unit copy for alpha inputs of invalid length.

# 2.0.0
- forked country_code package as no updates where comming through.
- Added countryName to all standard country codes.
- rebuilt the generation code in dart and tools are now part
of the package.

## [1.1.0]
Minimal Dart SDK version requirement is v3.5

## [1.0.0]
Stable, null-safe release
### Changed
- Requires Dart version >= 2.12

## [0.2.0-beta]
### Changed
- Refactored access to class values. Both ISO and user-assigned codes are 
accessible through `values` list.

### Added
- `index` getter to match enum behaviour
- `symbol` getter

## [0.1.0]
Initial release
