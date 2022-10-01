<!-- 
BSD 3-Clause License
Copyright (c) 2022, GM Consult Pty Ltd
Copyright (c) 2001, Dr Martin Porter,
Copyright (c) 2002, Richard Boulton.
All rights reserved. 
-->

[![GM Consult Pty Ltd](https://raw.githubusercontent.com/GM-Consult-Pty-Ltd/porter_2_stemmer/main/assets/images/porter_2_stemmer.png?raw=true "GM Consult Pty Ltd")](https://github.com/GM-Consult-Pty-Ltd)
## **Reduce a word to its root form using the Porter English stemming algorithm**

*Version 2.0.0 BREAKING CHANGES. The algorithm implementation has been moved to the [Porter2StemmerMixin](#porter2stemmermixin). The [Porter2Stemmer](#porter2stemmer-interface) is now an interface with a factory constructor. Please extend the [Porter2StemmerBase](#porter2stemmerbase-class) implementation class in stead of the [Porter2Stemmer](#porter2stemmer-interface) interface.*

DART implementation of the [Porter Stemming Algorithm](https://snowballstem.org/algorithms/english/stemmer.html), used for reducing a word to its word stem, base or root form.

Skip to section:
- [Overview](#overview)
- [Usage](#usage)
- [API](#api)
- [Definitions](#definitions)
- [References](#references)
- [Issues](#issues)

## Overview

This library is a DART implementation of the popular ["Porter" English stemming algorithm](https://snowballstem.org/algorithms/english/stemmer.html) for use in information retrieval applications. It exports the [Porter2Stemmer](#porter2stemmer-interface) class, and the  [Porter2StemmerExtension](#porter2stemmerextension-extension) String extension,

The Porter stemming algorithm is Copyright (c) 2001, Dr Martin Porter and Copyright (c) 2002, Richard Boulton and licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause). 

As of version 1.0.0, the [Porter2Stemmer class](#porter2stemmer-interface) achieves 99.66% accuracy when measured against the sample (Snowball) vocabulary. Taking into account the differences in implementation, this increases to 99.99%, or failure of 4 out of 29,417 terms.

Refer to the [references](#references) to learn more about the theory behind information retrieval systems.

### Departures from Snowball implementation

Terms that match the following criteria (after stripping opening/closing quotation marks and the possessive apostrophy "'s") are returned unchanged as they are considered to be acronyms, identifiers or non-language terms that have a specific meaning:
- terms that are in all-capitals, e.g. TSLA; and
- terms that contain any non-word characters (anything other than letters, apostrophes and hyphens), e.g. apple.com, alibaba:xnys.

This behaviour can be overriden by pre-processing text with a character filter that converts terms to lower-case and/or strips out non-word characters.

In this implementation of the English (Porter2) stemming algorithm:
* all quotation marks and apostrophies are converted to the standard single quote character U+0027; 
* all leading and trailing quotation marks are stripped from the term before processing begins;
* in Step 5, the trailing "e" is not removed from stems that end in "ue". For example, "tongues" is stemmed as tongue (strict implementation returns "tongu") and "picturesque" is returned unchanged rather than stemmed to "picturesqu"); and
* the `exceptions` and `kInvariantExceptions` are checked after every step in the algorithm to ensure exceptions are not missed at intermediate steps.

Additional default exceptions have been implemented as follows in the [latest version](https://pub.dev/packages/porter_2_stemmer/changelog):

- Terms that have no stem:
    {
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
      'andes': 'andes'
    }

- Terms that have no stem at the end of Step 1(a):
    {
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
    }

### Validation

A validator test is included in the repository [test folder](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/tree/main/test). 

The `Porter2Stemmer: VALIDATOR` test iterates through a hashmap of [terms](https://raw.githubusercontent.com/snowballstem/snowball-data/master/english/voc.txt) to expected [stems](https://raw.githubusercontent.com/snowballstem/snowball-data/master/english/output.txt) that contains 29,417 term/stem pairs.

As of version 1.0.0, the [Porter2Stemmer class](#porter2stemmer-interface) achieves 99.66% accuracy when measured against the sample (Snowball) vocabulary. Taking into account the differences in implementation, this increases to 99.99%, or failure of 4 out of 29,417 terms. The failed stems are:

* "congeners" => "congener" (expected "congen");
* "fluently" => "fluent" (expected "fluentli");
* "harkye" => "harki" (expected "harky"); and
* "lookye" => "looki" (expected "looky").

## API

The [API](https://pub.dev/documentation/porter_2_stemmer/latest/) exposes the [Porter2Stemmer class](#porter2stemmer-interface), an English language `stemmer` utility class and the  [Porter2StemmerExtension](#porter2stemmerextension-extension) String extension.

### Porter2Stemmer interface

The `Porter2Stemmer` interface exposes the `Porter2Stemmer.stem` function that reduces a term to its word stem, base or root form by stepping through the five steps of the `Porter2 (English) stemming algorithm`.

Terms that match a key in `Porter2Stemmer.exceptions` (after stripping quotation marks and possessive apostrophy `'s`) are stemmed by returning the corresponding value from `Porter2Stemmer.exceptions`.

The default exceptions used by `Porter2Stemmer` are:
  { 'skis': 'ski',
    'skies': 'sky',
    'dying': 'die',
    'lying': 'lie',
    'tying': 'tie',
    'idly': 'idl',
    'gently': 'gentl',
    'singly': 'singl' }

### Porter2StemmerMixin

 Each of the five stemmer steps is implemented as a public function that takes a term as parameter and returns a manipulated String after applying the step algorithm. The steps may therefore be overriden in sub-classes.

Terms that match the following criteria (after stripping quotation marks and possessive apostrophy "s") are returned unchanged as they are considered to be acronyms, identifiers or non-language terms that have a specific meaning:
* terms that are in all-capitals, e.g. TSLA;
* terms that contain any non-word characters (anything other than letters,  apostrophes and hyphens), e.g. apple.com, alibaba:xnys

Terms that match a key in `Porter2Stemmer.exceptions` (after stripping quotation marks and possessive apostrophy `'s`) are stemmed by returning the corresponding value from `Porter2Stemmer.exceptions`.

Terms may be converted to lowercase before processing if stemming of all-capitals terms is desired. Split terms that contain non-word characters to stem the term parts separately.

The algorithm steps are described fully [here](https://snowballstem.org/algorithms/english/stemmer.html).

### Porter2StemmerBase class

The `Porter2StemmerBase` class is an implementation class that mixes in the [Porter2StemmerMixin](#porter2stemmermixin). A const constructor is provided for sub classes.

### Porter2StemmerExtension

The [Porter2StemmerExtension]provides an extension method `String.stemPorter2` that reduces a term to its word stem, base or root form using the `Porter2 (English) stemming algorithm`.

Pass the `exceptions` parameter (a hashmap of String:String) to apply custom exceptions to the algorithm. The default exceptions are the static const `Porter2Stemmer.kExceptions`.

This extension method is a shortcut to `Porter2Stemmer.stem` method.

## Usage

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  porter_2_stemmer: ^1.0.0
```

In your library add the following import:

```dart
import 'package:porter_2_stemmer/porter_2_stemmer.dart';
```

A String extension is provided, and is the simplest way to get stemming.

```dart
final stem = term.stemPorter2();
```

To implement custom exceptions to the algorithm, provide the exceptions parameter (a hashmap of String:String) that provides the term (key) and its stem (value). 

The code below instantiates a Porter2Stemmer instance, passing in a custom exception for the term "TSLA".

```dart

  // Preserve the default exceptions.
  final exceptions = Map<String, String>.from(Porter2Stemmer.kExceptions);

  // Add a custom exception for "TSLA".
  exceptions['TSLA'] = 'tesla';

  // Instantiate the [Porter2Stemmer] instance using the custom [exceptions]
  final stemmer = Porter2Stemmer(exceptions: exceptions);

  // Get the stem for the [term].
  final stem = stemmer.stem(term);

```
[Examples](https://pub.dev/packages/porter_2_stemmer/example) are provided for both the extension method and the class method with custom exceptions. 

## Definitions

The following definitions are used throughout the [documentation](https://pub.dev/documentation/text_indexing/latest/):
* `corpus`- the collection of `documents` for which an `index` is maintained.
* `document` - a record in the `corpus`, that has a unique identifier (`docId`) in the `corpus`'s primary key and that contains one or more text fields that are indexed.
* `lemmatizer` - lemmatisation (or lemmatization) in linguistics is the process of grouping together the inflected forms of a word so they can be analysed as a single item, identified by the word's lemma, or dictionary form (from [Wikipedia](https://en.wikipedia.org/wiki/Lemmatisation)).
* `Porter2 stemming algorithm` - a English language `stemmer` developed as part of ["Snowball"](https://snowballstem.org/), a small string processing language designed for creating stemming algorithms for use in information retrieval. 
* `term` - a word or phrase that is indexed from the `corpus`. The `term` may differ from the actual word used in the corpus depending on the `tokenizer` used.
* `stemmer` -  stemming is the process of reducing inflected (or sometimes derived) words to their word stem, base or root form—generally a written word form (from [Wikipedia](https://en.wikipedia.org/wiki/Stemming)).
* `text` - the indexable content of a `document`.
* `token` - representation of a `term` in a text source returned by a `tokenizer`. The token may include information about the `term` such as its position(s) in the text or frequency of occurrence.
* `tokenizer` - a function that returns a collection of `token`s from `text`, after applying a character filter, `term` filter, `stemmer` and / or `lemmatizer`.
* `vocabulary` - the collection of `terms` indexed from the `corpus`.

## References

* [Porter, Dr Martin and Boulton, Richard, 2002, "*The English (Porter2) stemming algorithm*", Snowball, 2002](https://snowballstem.org/algorithms/english/stemmer.html)
* [Manning, Raghavan and Schütze, "*Introduction to Information Retrieval*", Cambridge University Press, 2008](https://nlp.stanford.edu/IR-book/pdf/irbookprint.pdf)
* [University of Cambridge, 2016 "*Information Retrieval*", course notes, Dr Ronan Cummins, 2016](https://www.cl.cam.ac.uk/teaching/1516/InfoRtrv/)
* [Wikipedia (1), "*Inverted Index*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Inverted_index)
* [Wikipedia (2), "*Lemmatisation*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Lemmatisation)
* [Wikipedia (3), "*Stemming*", from Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Stemming)

## Issues

If you find a bug please fill an [issue](https://github.com/GM-Consult-Pty-Ltd/porter_2_stemmer/issues).  

This project is a supporting package for a revenue project that has priority call on resources, so please be patient if we don't respond immediately to issues or pull requests.


