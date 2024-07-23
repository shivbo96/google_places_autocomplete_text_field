# Changelog 🪵

## 0.1.4

- Added support for custom decoration for suggestion items using the `suggestionDecoration` property.
- Introduced custom scroll physics for the suggestion list using the `physics` property.
- Modified `_overlayChild` to apply the new `suggestionDecoration` and `physics` properties.
- Updated the constructor of `GooglePlacesAutoCompleteTextFormField` to accept the new properties.
- Enhanced user experience with customizable decoration and scrolling behavior for suggestions.
- Updated `.gitignore` to exclude additional build artifacts, generated files, and IDE-specific directories.

#### Summary
- **Added**: `suggestionDecoration` property to customize the decoration of suggestion items.
- **Added**: `physics` property to customize the scroll physics of the suggestion list.
- **Updated**: `.gitignore` file to include more patterns for build artifacts, generated files, and IDE-specific directories.

## 0.1.3

* [Fix]: Removed the duplicate declaration of the fields `inputDecoration` and `decoration`, which were misleading. Now only the field `decoration` is available to assign a `InputDecoration`  to the `GooglePlacesAutoCompleteTextFormField`, following the `TextFormField` convention.

## 0.1.2

* [Add]: New argument `validator` now you can validate the field if it's used inside the Form widget. More information is available in the example.
* [Update]: Example updated.

## 0.1.1

* [Fix]: Fixed a bug where the Google API Url would not be correctly built if no proxy URL was provided.

## 0.1.0

* [Add]: Added compatibility for Flutter Web 🌐. Just pass the `GooglePlacesAutoCompleteTextFormField` a proxy URL and you're good to go!

## 0.0.3

* [Fix]: Fixed a bug on MacOS where clicking on the predictions would not be registered.

## 0.0.2

* [Add]: New argument `overlayContainer` so that you can now fully customize the appearance of the predictions as well!
* [Fix]: Fixed a bug where the overlay with the predictions would not be closed as soon as the focus is lost.

## 0.0.1

* Initial release of a fully customizable `TextFormField` that sends your input to the Google Places API and provides you with suggestions for autocompletion.
