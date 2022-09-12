// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// All rights reserved.

// Porter stemmer algorithm is Copyright (c) 2001, Dr Martin Porter, and
// Copyright (c) 2002, Richard Boulton, all rights reserved.

part 'porter_2_stemmer.extension.dart';

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
  /// value from [exceptions].
  ///
  /// Terms may be converted to lowercase before processing if stemming of
  /// all-capitals terms is desired. Split terms that contain non-word
  /// characters to stem the term parts separately.
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
        .replaceAll(RegExp('(?<=${_StemmerExtension.rVowels})(y)'), 'Y');
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
      term.replaceAll(RegExp(rQuotes), "'");

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
      final vowelcount = RegExp(rVowels).allMatches(stub).length;
      // If last letter of stub is vowel return unchanged
      if (RegExp(rVowels + r'(?=$)').allMatches(stub).isNotEmpty &&
          vowelcount == 1) {
        return term;
      }
      return RegExp(rVowels).allMatches(stub).isEmpty
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
      final stub = term.replaceSuffixes(kStep1BSuffixes);
      if (RegExp('$rVowels+').allMatches(stub).isNotEmpty) {
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
    return RegExp(r'(?<=\w)' + rNotVowels + r'(?=(ye|y|Y)$)')
            .allMatches(term)
            .isNotEmpty
        ? term.replaceAll(RegExp(r'(y|Y|ye)(?=$)'), 'i')
        : term;
  }

  /// Search for the longest key in [kStep2Suffixes], and, if found
  /// and in R1, replace with the corresponding value from [kStep2Suffixes].
  String step2(String term) {
    final e = exception(term);
    if (e != null) return e;
    final region1 = term.r1;
    if (region1 != null) {
      if (region1.endsWith('ogi') && term.endsWith('logi')) {
        return term.replaceAll(RegExp(r'(logi)(?=$)'), 'log');
      }
      final stub = term.replaceSuffixes(kStep2Suffixes, term.r1);
      if (stub.endsWith('li') && (stub.r1?.endsWith('li') ?? false)) {
        return stub.replaceAll(RegExp(r'(?<=[cdeghkmnrt])(li)(?=$)'), '');
      }
      return stub;
    }
    return term;
  }

  /// Search for the longest key in [kStep3Suffixes], and, if found
  /// and in R1, replace with the corresponding value from [kStep3Suffixes].
  ///
  /// If the String ends with 'ative', delete the suffix it is in R2.
  String step3(String term) {
    final e = exception(term);
    if (e != null) return e;
    return (term.r2 ?? '').endsWith('ative')
        ? term.replaceSuffix('ative', '')
        : term.r1 != null
            ? term.replaceSuffixes(kStep3Suffixes, term.r1)
            : term;
  }

  /// Search for the longest key in [kStep4Suffixes], and, if found
  /// and in R2, replace with the corresponding value from [kStep4Suffixes].
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
      return term.replaceSuffixes(kStep4Suffixes, region2);
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
  /// The String is looked up in the [kInvariantExceptions] and [exceptions]
  /// hashmaps and the value (or null) is returned as an exception to
  /// the algorithm.
  String? exception(String term) =>
      exceptions[term] ?? kInvariantExceptions[term];

  /// Look up the String in [kStep1AExceptions] and return the value or null.
  ///
  /// Used after [step1A] to deal with the exceptions in [kStep1AExceptions].
  String? step1AException(String term) => kStep1AExceptions[term];
  //

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

  /// Collection of terms that have no stem but do not fit the algorithm.
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

  /// Suffix hasmap for Step 1B.
  static const kStep1BSuffixes = {
    'ingly': '',
    'edly': '',
    'ing': '',
    'ed': '',
  };

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
  static const kStep3Suffixes = {
    'ational': 'ate',
    'tional': 'tion',
    'alize': 'al',
    'icate': 'ic',
    'iciti': 'ic',
    'ical': 'ic',
    'ness': '',
    'ful': '',
  };

  /// Suffix hasmap for Step 4.
  static const kStep4Suffixes = {
    'ement': '',
    'ance': '',
    'ence': '',
    'able': '',
    'ible': '',
    'ment': '',
    'sion': '',
    'tion': '',
    'ant': '',
    'ent': '',
    'ism': '',
    'ate': '',
    'iti': '',
    'ous': '',
    'ive': '',
    'ize': '',
    'al': '',
    'er': '',
    'ic': '',
  };

  /// Regular expression selector for characters that are vowels.
  static const rVowels = _StemmerExtension.rVowels;

  /// Selector for all single or double quotation marks and apostrophes.
  static const rQuotes = _StemmerExtension.rQuotes;

  /// Regular expression selector for characters that are NOT vowels.
  ///
  /// As the term is in lowercase, this also selects all uppercase letters and,
  /// for that matter, any character not in ('a', 'e', 'i', 'o', 'u', 'y').
  static const rNotVowels = _StemmerExtension.rNotVowels;
}
