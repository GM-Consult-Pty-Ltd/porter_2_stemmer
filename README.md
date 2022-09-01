# porter_2_stemmer
DART implementation of the [Porter Stemming Algorithm](https://snowballstem.org/algorithms/), used for reducing a word to its word stem, base or root form.

## What is the Porter Stemming Algorithm?

The Porter Stemming Algorithm (or 'Porter stemmer') is a process for removing the commoner morphological and inflexional endings from words in English. Its main use is as part of a term normalisation process that is usually done when setting up information retrieval systems.

The English (Porter2) stemming algorithm was developed as part of "Snowball", a small string processing language designed for creating stemming algorithms for use in information retrieval.

The Porter 2 algorithm is Copyright (c) 2001, Dr Martin Porter and Copyright (c) 2002, Richard Boulton and licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause). 

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  porter_2_stemmer: <latest_version>
```

In your library add the following import:

```dart
import 'package:porter_2_stemmer/porter_2_stemmer.dart';
```

## Usage

After importing the package simply use the extension method as follows:

```dart
// A term that has a stem.
final term = 'generically';
// Call the extension method.
final stem = term.stemPorter2();
// Print the result.
print('$term => $stem'); // prints "generically => generic"
```

To implement custom exceptions to the algorithm, provide a hashmap of String:String that provides the
term (key) and its stem (value). The default exceptions are:
```dart
/// Default exceptions used by [Porter2Stemmer].
static const kExceptions = {
  'skis': 'ski',
  'skies': 'sky',
  'dying': 'die',
  'lying': 'lie',
  'tying': 'tie',
  'idly': 'idl',
  'gently': 'gentl',
  'ugly': 'ugli',
  'early': 'earli',
  'only': 'onli',
  'singly': 'singl',
};
```

## Quotation Marks, apostrophes and non-language terms

This implementation:
* converts all quotation marks and apostrophies to a standard single quote character U+0027 (also ASCII hex 27); and
* strips all leading and trailing quotation marks from the term before processing begins.

The following terms are returned unchanged as they are considered to be acronyms, identifiers or non-language terms that have a specific meaning:
* terms that are in all-capitals, e.g. TSLA;
* terms that contain any non-word characters (anything other than letters, apostrophes and hyphens), e.g. apple.com, alibaba:xnys.

Terms may be converted to lowercase before processing if stemming of the all-capitals terms is desired. Split terms that contain non-word characters to stem the term parts separately.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/issues).  
If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/pulls). 

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.
