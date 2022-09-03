// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// Copyright (c) 2001, Dr Martin Porter,
// Copyright (c) 2002, Richard Boulton.
// All rights reserved.

part 'stemmer.extension.dart';

/// DART implementation of the Porter Stemming Algorithm
/// (see https://snowballstem.org/algorithms/), used for reducing a word to
/// its word stem, base or root form.
class Porter2Stemmer {
  //

  /// Instantiates a const [Porter2Stemmer] instance.
  ///
  /// Parameter [exceptions] is a hashmap of terms (keys) with their stem
  /// values that will be returned rather than processing the term. The default
  /// exceptions are [Porter2Stemmer.kExceptions].
  const Porter2Stemmer({Map<String, String>? exceptions})
      : exceptions = exceptions ?? Porter2Stemmer.kExceptions;

  /// A hashmap of terms (keys) with their stem values that will be returned
  /// rather than being processed by the stemmer.
  ///
  /// The default is [Porter2Stemmer.kExceptions].
  final Map<String, String> exceptions;

  /// Reduces the String to its word stem, base or root form using the
  /// [Porter2Stemmer] English language stemming algorithm.
  ///
  /// Terms that match the following criteria (after stripping quotation marks
  /// and possessive apostrophy "s") are returned unchanged as they are
  /// considered to be acronyms, identifiers or non-language terms that have
  /// a specific meaning:
  /// - terms that are in all-capitals, e.g. TSLA;
  /// - terms that contain any non-word characters (anything other than letters,
  ///   apostrophes and hyphens), e.g. apple.com, alibaba:xnys
  ///
  /// Terms that match a key in [exceptions] (after stripping quotation marks
  /// and possessive apostrophy "s") are stemmed by returning the corresponding
  /// value from [exceptions.]
  ///
  /// Terms may be converted to lowercase before processing if stemming of
  /// all-capitals terms is desired. Split terms that contain non-word
  /// characters to stem the term parts separately.
  String stem(String term) {
    // change all forms of apostrophes and quotation marks to [']
    term = term.normalizeQuotesAndApostrophes();

    // remove all enclosing quotation marks.
    term = term.removeEnclosingQuotes();

    // remove trailing "'s" (apostrophied s's).
    term = term.stepZero();

    // look up any rule exceptions and return it if found.
    // return terms with no stem unchanged
    var exception = term.exception(exceptions);

    // return the exception if found
    if (exception != null) {
      return exception;
    }

    // return words in all caps unchanged.
    // return words with non-word characters  (not [a-z, A-Z, ', and -])
    // unchanged
    if (term.isIdentifier) {
      return term;
    }

    // convert the term to lowercase for processing
    term = term.toLowerCase();

    // set initial y, or y after a vowel, to Y
    term = term.exception(exceptions) ?? term.replaceYs();

    // call Step 1(a)
    term = term.exception(exceptions) ?? term.step1A();

    // check for alghorithm exceptions at end of Step 1(a)
    exception = term.exception(exceptions) ?? term.step1AException();

    // return the exception if found
    if (exception != null) {
      return exception;
    }

    // call Step 1(a)
    term = term.exception(exceptions) ?? term.step1B();

    // call Step 1(a)
    term = term.exception(exceptions) ?? term.step1C();

    // call Step 1(a)
    term = term.exception(exceptions) ?? term.step2();

    // call Step 1(a)
    term = term.exception(exceptions) ?? term.step3();

    // call Step 1(a)
    term = term.exception(exceptions) ?? term.step4();

    // call Step 1(a)
    term = term.exception(exceptions) ?? term.step5();

    // replace all upper-case "Y"s with "y"
    term = term.exception(exceptions) ?? term.normalizeYs();

    return term.exception(exceptions) ?? term;
  }

  /// Default exceptions used by [Porter2Stemmer].
  static const kExceptions = {
    'skis': 'ski',
    'vehement': 'vehement',
    'statement': 'statement',
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

  //
}
