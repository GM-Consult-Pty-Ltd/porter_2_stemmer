// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// All rights reserved.

import 'porter_2_stemmer_constants.dart';
import 'porter_2_stemmer_extension.dart';

// Porter stemmer algorithm is Copyright (c) 2001, Dr Martin Porter, and
// Copyright (c) 2002, Richard Boulton, all rights reserved.

/// DART implementation of the Porter Stemming Algorithm
/// (see https://snowballstem.org/algorithms/), used for reducing a word to
/// its word stem, base or root form.
abstract class Porter2Stemmer {
  //

  ///
  factory Porter2Stemmer({Map<String, String>? exceptions}) =>
      _Porter2StemmerImpl(exceptions ?? Porter2StemmerConstants.kExceptions);

  /// A hashmap of terms (keys) with their stem values that will be returned
  /// rather than being processed by the stemmer.
  ///
  /// The default is [Porter2StemmerConstants.kExceptions].
  Map<String, String> get exceptions;

  /// Reduces the String to its word stem, base or root form using the
  /// [Porter2StemmerMixin] English language stemming algorithm.
  ///
  /// Terms that match a key in [exceptions] are stemmed by returning the
  /// corresponding value from [exceptions].
  String stem(String term);

  //
}

/// Implementation class used by [Porter2Stemmer] unnamed factory
class _Porter2StemmerImpl with Porter2StemmerMixin implements Porter2Stemmer {
//

  @override
  final Map<String, String> exceptions;

  /// Instantiates a const [_Porter2StemmerImpl] instance.
  ///
  /// Parameter [exceptions] is a hashmap of terms (keys) with their stem
  /// values that will be returned rather than processing the term. The default
  /// exceptions are [Porter2StemmerConstants.kExceptions].
  const _Porter2StemmerImpl(this.exceptions);
}

/// Base class that mixes in the [Porter2StemmerMixin] mixin.
abstract class Porter2StemmerBase
    with Porter2StemmerMixin
    implements Porter2Stemmer {
//
  /// Instantiates a const [Porter2StemmerBase] instance.
  const Porter2StemmerBase();
}

/// Implements the [Porter2Stemmer.stem] method.
abstract class Porter2StemmerMixin implements Porter2Stemmer {
  //

  /// Reduces the String to its word stem, base or root form using the
  /// [Porter2StemmerMixin] English language stemming algorithm.
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
  /// value from [exceptions].
  ///
  /// Terms may be converted to lowercase before processing if stemming of
  /// all-capitals terms is desired. Split terms that contain non-word
  /// characters to stem the term parts separately.
  @override
  String stem(String term) {
    //

    // change all forms of apostrophes and quotation marks to [']
    // remove all enclosing quotation marks,
    // then call step 0.
    term = step0(removeEnclosingQuotes(normalizeQuotesAndApostrophes(term)));

    // check if word is identifier and return if true
    if (term.isIdentifier) {
      return term;
    }
    // call Step 1(a) after converting to lower-case and performing
    // y-substitution.
    term = step1A(replaceYs(term.toLowerCase()));

    // check for exceptions at end of Step 1(a) and return if found
    return step1AException(term) ??
        // else, call steps 1(b) through 5
        // then replace all upper-case "Y"s with "y"
        normalizeYs(step5(step4(step3(step2(step1C(step1B(term)))))));
  }

  /// Set initial y, or y after a vowel, to Y.
  ///
  /// See note on vowel marking at
  /// http://snowball.tartarus.org/texts/vowelmarking.html
  String replaceYs(String term) {
    final e = exception(term);
    if (e != null) return e;
    return term
        .replaceFirst(RegExp(r'^y'), 'Y')
        .replaceAll(RegExp('(?<=${Porter2StemmerConstants.rVowels})(y)'), 'Y');
  }

  /// Set initial y, or y after a vowel, to Y.
  ///
  /// See note on vowel marking at
  /// http://snowball.tartarus.org/texts/vowelmarking.html
  String normalizeYs(String term) => term.replaceAll('Y', 'y');

  /// Trims all quotation marks from start and end of String.
  String removeEnclosingQuotes(String term) =>
      term.replaceAll(RegExp(r"(^'+)|('+(?=$))"), '');

  /// Replace all forms of apostrophe or quotation mar with U+0027.
  String normalizeQuotesAndApostrophes(String term) =>
      term.replaceAll(RegExp(Porter2StemmerConstants.rQuotes), "'");

  /// Remove longest of "'", "'s" or "'s'" from end of term.
  ///
  /// The string instance must be in lower case.
  ///
  /// An apostrophe (') may be regarded as a letter. See note on apostrophes
  /// in English (http://snowball.tartarus.org/texts/apostrophe.html).
  String step0(String term) {
    final e = exception(term);
    if (e != null) return e;
    return exception(term) ??
        term.replaceAll(RegExp(r"(('s')|'|('s))(?=$)"), '');
  }

  /// Search for the longest among the following suffixes, and perform the action
  /// indicated.
  ///
  /// - replace 'sses' with 'ss';
  /// - replace 'ied' or 'ies' with 'i' if preceded by more than one letter,
  ///   otherwise by ie (so ties -> tie, cries -> cri);
  /// - delete 's'  if the preceding word part contains a vowel not
  ///   immediately before the s (so gas and this retain the s, gaps and
  ///   kiwis lose it);
  /// - if the term ends in 'us' or 'ss' do nothing
  ///
  /// Following [step1A], leave the following invariant:
  /// - 'inning', 'outing', 'canning', 'herring', 'earring', 'proceed',
  ///   'exceed', 'succeed'.
  String step1A(String term) {
    final e = exception(term);
    if (e != null) return e;
    if (term.endsWith('sses')) {
      return term.replaceSuffix('sses', 'ss');
    }
    if (term.endsWith('ied') || term.endsWith('ies')) {
      final stub = term.substring(0, term.length - 3);
      return stub.length > 1 ? '${stub}i' : '${stub}ie';
    }
    // if (term.endsWith('oes')) {
    //   return term.replaceAll(r'oes(?=$)', 'o');
    // }
    if (term.endsWith('us') || term.endsWith('ss')) {
      return term;
    }
    if (term.endsWith('s')) {
      final stub = term.substring(0, term.length - 1);
      final vowelcount =
          RegExp(Porter2StemmerConstants.rVowels).allMatches(stub).length;
      // If last letter of stub is vowel return unchanged
      if (RegExp(Porter2StemmerConstants.rVowels + r'(?=$)')
              .allMatches(stub)
              .isNotEmpty &&
          vowelcount == 1) {
        return term;
      }
      return RegExp(Porter2StemmerConstants.rVowels).allMatches(stub).isEmpty
          ? term
          : term.substring(0, term.length - 1);
    }
    return term;
  }

  /// Search for the longest among the following suffixes, and perform the
  /// action indicated.
  ///
  /// If the term ends in 'eed' or 'eedly', replace with 'ee' if the suffix is
  /// in (non-null) R1.
  ///
  /// If term ends in 'ed', 'edly',  'ing' or 'ingly' delete the suffix if
  /// the preceding word part contains a vowel, and after the deletion:
  /// - if the word ends at, bl or iz add e (so luxuriat -> luxuriate), or
  /// - if the word ends with a double remove the last letter (so hopp -> hop),
  ///   or if the word is short, add e (so hop -> hope)
  String step1B(String term) {
    final e = exception(term);
    if (e != null) return e;
    final region1 = term.r1;
    if ((term.endsWith('eed') || term.endsWith('eedly'))) {
      if (region1 != null &&
          (region1.endsWith('eed') || region1.endsWith('eedly'))) {
        return term.replaceAll(RegExp(r'(?<=[a-z])(eed|eedly)(?=$)'), 'ee');
      }
      return term;
    }
    if (term.endsWith('ed') ||
        term.endsWith('ing') ||
        term.endsWith('edly') ||
        term.endsWith('ingly')) {
      final stub = term.replaceSuffixes(step1BSuffixes);
      if (RegExp('${Porter2StemmerConstants.rVowels}+')
          .allMatches(stub)
          .isNotEmpty) {
        if (stub.endsWith('at') ||
            stub.endsWith('bl') ||
            stub.endsWith('iz') ||
            term.isShortWord) {
          return '${stub}e';
        }
        if (stub.endsWithDouble) {
          return stub.substring(0, stub.length - 1);
        }
        if (stub.r1 == null && stub.endsWithShortSyllable) {
          return '${stub}e';
        }
        return stub;
      }
    }
    return term;
  }

  /// Replace suffix y or Y by i if preceded by a non-vowel which is not the
  /// first letter of the word (so cry -> cri, by -> by, say -> say
  String step1C(String term) {
    final e = exception(term);
    if (e != null) return e;
    return RegExp(r'(?<=\w)' +
                Porter2StemmerConstants.rNotVowels +
                r'(?=(ye|y|Y)$)')
            .allMatches(term)
            .isNotEmpty
        ? term.replaceAll(RegExp(r'(y|Y|ye)(?=$)'), 'i')
        : term;
  }

  /// Search for the longest key in [step2Suffixes], and, if found
  /// and in R1, replace with the corresponding value from [step2Suffixes].
  String step2(String term) {
    final e = exception(term);
    if (e != null) return e;
    final region1 = term.r1;
    if (region1 != null) {
      if (region1.endsWith('ogi') && term.endsWith('logi')) {
        return term.replaceAll(RegExp(r'(logi)(?=$)'), 'log');
      }
      final stub = term.replaceSuffixes(step2Suffixes, term.r1);
      if (stub.endsWith('li') && (stub.r1?.endsWith('li') ?? false)) {
        return stub.replaceAll(RegExp(r'(?<=[cdeghkmnrt])(li)(?=$)'), '');
      }
      return stub;
    }
    return term;
  }

  /// Search for the longest key in [step3Suffixes], and, if found
  /// and in R1, replace with the corresponding value from [step3Suffixes].
  ///
  /// If the String ends with 'ative', delete the suffix it is in R2.
  String step3(String term) {
    final e = exception(term);
    if (e != null) return e;
    return (term.r2 ?? '').endsWith('ative')
        ? term.replaceSuffix('ative', '')
        : term.r1 != null
            ? term.replaceSuffixes(step3Suffixes, term.r1)
            : term;
  }

  /// Search for the longest key in [step4Suffixes], and, if found
  /// and in R2, replace with the corresponding value from [step4Suffixes].
  ///
  /// If R2 ends with 'ion', delete the suffix if preceded by 's' or 't'.
  String step4(String term) {
    final e = exception(term);
    if (e != null) return e;
    final region2 = term.r2;
    if (region2 != null) {
      if (region2.endsWith('ion') &&
          (term.endsWith('sion') || term.endsWith('tion'))) {
        return term.replaceSuffix('ion', '');
      }
      return term.replaceSuffixes(step4Suffixes, region2);
    }

    return term;
  }

  /// Search for the the following suffixes, and, if found:
  /// - "e": delete if in R2, or in R1 and not preceded by a short
  ///   syllable; or
  /// - "l": delete if in R2 and preceded by an "l".
  String step5(String term) {
    final e = exception(term);
    if (e != null) return e;
    final region1 = term.r1;
    final region2 = term.r2;
    if (region1 != null && (term.endsWith('e') || term.endsWith('l'))) {
      final stub = term.substring(0, term.length - 1);
      if (term.endsWith('e') && !term.endsWith('ue')) {
        return (region2 != null || !stub.endsWithShortSyllable) ? stub : term;
      }
      return ((region2 ?? '').endsWith('l') && stub.endsWith('l'))
          ? stub
          : term;
    }
    return term;
  }

  /// If the String `term.isIdentifier]`, it is returned as an exception to
  /// the algorithm.
  ///
  /// The String is looked up in the [invariantExceptions] and [exceptions]
  /// hashmaps and the value (or null) is returned as an exception to
  /// the algorithm.
  String? exception(String term) =>
      exceptions[term] ?? invariantExceptions[term];

  /// Look up the String in [step1AExceptions] and return the value or null.
  ///
  /// Used after [step1A] to deal with the exceptions in [step1AExceptions].
  String? step1AException(String term) => step1AExceptions[term];
  //

  /// Collection of terms that have no stem at the end of Step 1(a).
  Map<String, String> get step1AExceptions =>
      Porter2StemmerConstants.kStep1AExceptions;

  /// Collection of terms that have no stem but do not fit the algorithm.
  Map<String, String> get invariantExceptions =>
      Porter2StemmerConstants.kInvariantExceptions;

  /// Suffix hasmap for Step 1B.
  Map<String, String> get step1BSuffixes =>
      Porter2StemmerConstants.kStep1BSuffixes;

  /// Suffix hasmap for Step 2.
  Map<String, String> get step2Suffixes => kStep2Suffixes;

  /// Suffix hasmap for Step 2.
  static const kStep2Suffixes = {
    'ization': 'ize',
    'ational': 'ate',
    'fulness': 'ful',
    'ousness': 'ous',
    'iveness': 'ive',
    'tional': 'tion',
    'biliti': 'ble',
    'lessli': 'less',
    'entli': 'ent',
    'ation': 'ate',
    'alism': 'al',
    'aliti': 'al',
    'ousli': 'ous',
    'iviti': 'ive',
    'fulli': 'ful',
    'enci': 'ence',
    'anci': 'ance',
    'abli': 'able',
    'izer': 'ize',
    'ator': 'ate',
    'alli': 'al',
    'logi': 'log',
    'bli': 'ble',
  };

  /// Suffix hasmap for Step 3.
  Map<String, String> get step3Suffixes =>
      Porter2StemmerConstants.kStep3Suffixes;

  /// Suffix hasmap for Step 4.
  Map<String, String> get step4Suffixes =>
      Porter2StemmerConstants.kStep4Suffixes;
}

/// Extends [String] to provide the [stemPorter2] method.
extension Porter2StemmerExtension on String {
  //

  /// Reduces the String to its word stem, base or root form.
  /// using the [Porter2Stemmer] English language stemming algorithm.
  ///
  /// To implement custom exceptions to the algorithm, provide [exceptions]
  /// where the key is the term and the value is its stem (value).
  ///
  /// The default exceptions are [Porter2StemmerConstants.kExceptions].
  ///
  /// This is a shortcut to [Porter2Stemmer.stem] function.
  String stemPorter2([Map<String, String>? exceptions]) =>
      Porter2Stemmer(exceptions: exceptions).stem(this);
}

/// Private extension functions on [String] called by [Porter2StemmerMixin].
extension _StemmerExtension on String {
  //

  /// If the String ends with any of [suffixes.keys], replace the ending with
  /// [suffixes.values] by calling [replaceSuffix].
  String replaceSuffixes(Map<String, String> suffixes, [String? region]) {
    for (final entry in suffixes.entries) {
      final suffix = entry.key;
      if (endsWith(suffix)) {
        if (region?.endsWith(suffix) ?? true) {
          final replacement = entry.value;
          final regex = RegExp('$suffix\$');
          return replaceAll(regex, replacement);
        }
        return this;
      }
    }
    return this;
  }

  /// If the String ends with any of [suffix], replace the ending with
  /// [replacement].
  String replaceSuffix(String suffix, String replacement) =>
      replaceAll(RegExp('$suffix\$'), replacement);
}
