<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
Copyright (c) 2001, Dr Martin Porter,
Copyright (c) 2002, Richard Boulton.
All rights reserved. 
-->

# porter_2_stemmer
DART implementation of the [Porter Stemming Algorithm](https://snowballstem.org/algorithms/), used for reducing a word to its word stem, base or root form.

This implementation achieves 98.7% success rate on the sample [vocabulary](http://snowball.tartarus.org/algorithms/english/diffs.txt) (29,417 terms), improving with each version.

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

A string extension is provided, and is the simplest way to get stemming:

```dart
import 'package:porter_2_stemmer/porter_2_stemmer.dart';

/// Iterate through a collection of terms/words and print the stem for each
/// term.
void main() {
  //

  /// collection of terms/words for which stems are printed.
  final terms = [
    'sky’s',
    'skis',
    'TSLA',
    'APPLE:NASDAQ',
    'consolatory',
    '"news"',
    "mother's",
    'generally',
    'consignment'
  ];

  /// iterate through the [terms] and print the stem for each term.
  for (final term in terms) {
    //

    // get the stem for the [term] by calling the stem2Porter() extension method.
    final stem = term.stemPorter2();

    // print the [term => stem].
    print('$term => $stem');
  }
}

```

Alternatively, instantiate a Porter2Stemmer instance, optionally passing your preferred exceptions,
and call the stem method.

```dart
import 'package:porter_2_stemmer/porter_2_stemmer.dart';

/// Instantiates a [Porter2Stemmer] instance using custom a exception for
/// the term "TSLA".
///
/// Prints the terms and their stems.
void main() {
  //

  // collection of terms/words for which stems are printed.
  final terms = [
    'sky’s',
    'skis',
    'TSLA',
    'APPLE:NASDAQ',
    'apple.com',
    'consolatory',
    '"news"',
    "mother's",
    'generally',
    'consignment'
  ];

  // preserve the default exceptions.
  final exceptions = Map<String, String>.from(Porter2Stemmer.kExceptions);

  // add a custom exception for "TSLA".
  exceptions['TSLA'] = 'tesla';

  // instantiate the [Porter2Stemmer] instance using the custom [exceptions]
  final stemmer = Porter2Stemmer(exceptions: exceptions);

  /// iterate through the [terms] and print the stem for each term.
  for (final term in terms) {

    // get the stem for the [term].
    final stem = stemmer.stem(term);

    // print the [term => stem].
    print('$term => $stem');
  }
}

```

To implement custom exceptions to the algorithm, provide the exceptions parameter (a hashmap of String:String) that provides the term (key) and its stem (value). The default exceptions are:
```dart
Default exceptions used by [Porter2Stemmer].
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

  Terms that match the following criteria (after stripping quotation marks   and possessive apostrophy "s") re returned unchanged as they are considered to be acronyms, identifiers or non-language terms that have a specific meaning:
  - terms that are in all-capitals, e.g. TSLA;
  - terms that contain any non-word characters (anything other than letters, apostrophes and hyphens), e.g. apple.com, alibaba:xnys

Terms may be converted to lowercase before processing if stemming of the all-capitals terms is desired. Split terms that contain non-word characters to stem the term parts separately.

## Contributions

Feel free to contribute to this project:
* If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/issues).  
* If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/pulls). 

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.
