<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
Copyright (c) 2001, Dr Martin Porter,
Copyright (c) 2002, Richard Boulton.
All rights reserved. 
-->

# porter_2_stemmer
DART implementation of the [Porter Stemming Algorithm](https://snowballstem.org/algorithms/english/stemmer.html), used for reducing a word to its word stem, base or root form.

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  porter_2_stemmer: [latest version](https://pub.dev/packages/porter_2_stemmer/changelog)
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

  // print a heading
  print('Example usage of Porter2Stemmer extension');

  /// Iterate through the [terms] and print the stem for each term.
  for (final term in terms) {
    // Get the stem for the [term] by calling the stem2Porter() extension
    // method.
    final stem = term.stemPorter2();

    // Print the [term => stem].
    print('$term => $stem');
  }
}

```

To implement custom exceptions to the algorithm, provide the exceptions parameter (a hashmap of String:String) that provides the term (key) and its stem (value). 

The next example instantiates a Porter2Stemmer instance, and passes in aa custom exception for the term "TSLA".

```dart
import 'package:porter_2_stemmer/porter_2_stemmer.dart';

/// Instantiates a [Porter2Stemmer] instance using a custom exception for
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

  // print a heading
  print('Example usage of Porter2Stemmer.stem method');

  // Preserve the default exceptions.
  final exceptions = Map<String, String>.from(Porter2Stemmer.kExceptions);

  // Add a custom exception for "TSLA".
  exceptions['TSLA'] = 'tesla';

  // Instantiate the [Porter2Stemmer] instance using the custom [exceptions]
  final stemmer = Porter2Stemmer(exceptions: exceptions);

  /// Iterate through the [terms] and print the stem for each term.
  for (final term in terms) {
    // Get the stem for the [term].
    final stem = stemmer.stem(term);

    // Print the [term => stem].
    print('$term => $stem');
  }
}

```

## What is the Porter Stemming Algorithm?

A stemmer is a process for removing the commoner morphological and inflexional endings from words in English. Its main use is as part of a term normalisation process that is usually done when setting up information retrieval systems.

The English (Porter2) stemming algorithm implemented in `Porter2Stemmer` was developed as part of "Snowball", a small string processing language designed for creating stemming algorithms for use in information retrieval.

The Porter Stemming Algorithm is Copyright (c) 2001, Dr Martin Porter and Copyright (c) 2002, Richard Boulton and licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause). 

## Departures from Snowball implementation

Terms that match the following criteria (after stripping opening/closing quotation marks and the possessive apostrophy "'s") are returned unchanged as they are considered to be acronyms, identifiers or non-language terms that have a specific meaning:
- terms that are in all-capitals, e.g. TSLA;
- terms that contain any non-word characters (anything other than letters, apostrophes and hyphens), e.g. apple.com, alibaba:xnys.

This behaviour can be overriden by pre-processing text with a character filter to change terms to lower-case and strip out non-word characters.

In this implementation of the English (Porter2) stemming algorithm:
* all quotation marks and apostrophies are converted to a standard single quote character U+0027 (also ASCII hex 27); 
* all leading and trailing quotation marks are stripped from the term before processing begins.
* in Step 5, the trailing "e" is not removed from stems that end in "ue". For example, "tongues" is stemmed as tongue (strict implementation returns "tongu") and "picturesque" is returned unchanged rather than stemmed to "picturesqu").
* the `exceptions` and `kInvariantExceptions` are checked after every step in the algorith
to ensure exceptions are not missed at intermediate steps.

Additional default exceptions have been implemented as follows in the [latest version](https://pub.dev/packages/porter_2_stemmer/changelog):

```dart

  /// Collection of default exceptions used by [Porter2Stemmer].
  static const kExceptions = {
    'skis': 'ski',
    'skies': 'sky',
    'dying': 'die',
    'lying': 'lie',
    'tying': 'tie',
    'idly': 'idl',
    'gently': 'gentl',
    'singly': 'singl',
  };

  /// Collection of terms that have no stem.
  static const kInvariantExceptions = {
    'sky': 'sky',
    'bye': 'bye',
    'ugly': 'ugly',
    'early': 'early',
    'only': 'only',
    'goodbye': 'goodbye',
    'commune': 'commune',
    'skye': 'skye',
    'news': 'news',
    'howe': 'howe',
    'atlas': 'atlas',
    'cosmos': 'cosmos',
    'bias': 'bias',
    'andes': 'andes',
  };

    /// Collection of terms that have no stem at the end of Step 1(a).
  static const kStep1AExceptions = {
    'inning': 'inning',
    'proceed': 'proceed',
    'goodbye': 'goodbye',
    'commune': 'commune',
    'herring': 'herring',
    'earring': 'earring',
    'outing': 'outing',
    'exceed': 'exceed',
    'canning': 'canning',
    'succeed': 'succeed',
    'doing': 'do'
  };
```

## Validation

A validator test is included in the repository as part of the [test folder](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/tree/main/test). 

The 'Porter2Stemmer: VALIDATOR' test iterates through a hashmap of [terms](https://raw.githubusercontent.com/snowballstem/snowball-data/master/english/voc.txt) to expected [stems](https://raw.githubusercontent.com/snowballstem/snowball-data/master/english/output.txt) that
contains 29,417 term/stem pairs.

As of [latest version](https://pub.dev/packages/porter_2_stemmer/changelog), the `Porter2Stemmer` achieves 99.66% accuracy when measured against the
sample (Snowball) vocabulary. Taking into account the differences in implementation, this 
increases to 99.99%, or failure of 4/29,417 terms. The failed stems are:

* "congeners" => "congener" (expected "congen");
* "fluently" => "fluent" (expected "fluentli");
* "harkye" => "harki" (expected "harky"); and
* "lookye" => "looki" (expected "looky").

## Issues

If you find a bug please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/issues).  

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.
