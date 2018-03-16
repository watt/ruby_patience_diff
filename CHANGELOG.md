# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

This is a breaking update. The API has changed somewhat, and HTML formatting has been removed.

### Added
* Tests!

### Changed
* Grouping behavior moved from `SequenceMatcher` to a new class, `ContextGrouper`.
* `Differ` now takes a formatter in its initializer instead of the diffing methods.
* `Formatter` has been replaced by `UnifiedFormatter`, which has a much simpler public API.
* Updated and modernized some internals.

### Deprecated
* The `#grouped_opcodes` method of `SequenceMatcher`. Use a `ContextGrouper` on the result of `#diff_opcodes` instead, for the same result.

### Removed
* HTML formatter
* The `--debug` option, which only affected error output. It's now always on.

## [1.1.0] - 2012-08-12
### Added
* Introduced HTML output

### Fixed
* Fixed some major bugs in the diffing algorithm

## [1.0.1] - 2012-06-19

### Added
* Added command-line options
* A little bit of documentation

### Changed
* Renamed gem from 'ruby_patience_diff' to just 'patience_diff'

### Fixed
* Fixed basically everything

## 1.0.0 - 2012-06-16

### Added
* First release

[Unreleased]: https://github.com/watt/ruby_patience_diff/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/watt/ruby_patience_diff/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/watt/ruby_patience_diff/compare/v1.0.0...v1.0.1
