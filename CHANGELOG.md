## [1.1.1]
- SDK constraint set to `^3.5.0`, matching the minimum announced in 1.1.0
- `CountryCode.user` and `CountryCode.assign` now validate input at runtime
(previously `assert`s, stripped in release builds): alpha codes must be exactly
2/3 uppercase ASCII letters, and at least one code is required. Throws `ArgumentError`.
- Fixed pub.dev topics, removed deprecated `uploader` field, removed library name
- Updated `lints` to 5.x, dropped removed `package_api_docs` lint

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