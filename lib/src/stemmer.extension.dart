// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// Copyright (c) 2001, Dr Martin Porter,
// Copyright (c) 2002, Richard Boulton.
// All rights reserved.

// ignore_for_file: prefer_interpolation_to_compose_strings

part of 'stemmer.dart';

/// Private extension functions on [String] called by [Porter2Stemmer].
extension _StemmerExtension on String {
  //

  /// Words starting with any of the following have a different [r1] to
  /// the algorithm.
  ///
  /// If the words begins with  (gener, commun or arsen), R1 is the remainder of the
  /// word after gener, commun or arsen is removed from the beginning.
  static const kRegion1Exceptions = ['gener', 'commun', 'arsen'];

  /// Look up the String in [kStep1AExceptions] and return the value or null.
  ///
  /// Used after [step1A] to deal with the exceptions in
  /// [kStep1AExceptions.keys].
  String? step1AException() => kStep1AExceptions[this];

  /// If the String [isIdentifier], it is returned as an exception to
  /// the algorithm.
  ///
  /// The String is looked up in the [kInvariantExceptions] and [exceptions]
  /// hashmaps and the value (or null) is returned as an exception to
  /// the algorithm.
  String? exception(Map<String, String> exceptions) =>
      kInvariantExceptions[this] ?? exceptions[this];

//Iterable<String> invariantExceptions,

  /// Selector that matches any character not a letter, a hyphen
  /// or apostrophe.
  static const rEnglishNonWordChars = "[^a-zA-Z'-]+";

  /// Returns true if:
  /// - the String is all aupper case (e.g. TSLA); or
  /// - the lowercase version of the String contains any [rEnglishNonWordChars].
  bool get isIdentifier =>
      toUpperCase() == this ||
      RegExp(rEnglishNonWordChars).allMatches(this).isNotEmpty;

  /// The region after the first non-vowel following a vowel, or the end of
  /// the word if there is no such non-vowel.
  ///
  /// If the words begins gener, commun or arsen, [r1] is the remainder of the
  /// word after gener, commun or arsen is removed from the beginning.
  ///
  /// See note on R1 and R2  http://snowball.tartarus.org/texts/r1r2.html.
  String? get r1 {
    for (final x in kRegion1Exceptions) {
      if (startsWith(x)) {
        return replaceFirst(x, '');
      }
    }
    return RegExp(r'(?<=(' + rVowels + rNotVowels + r'))\w+(?=$)')
        .firstMatch(this)
        ?.group(0);
  }

  /// The region after the first non-vowel following a vowel in [r1], or the
  /// end of the word if there is no such non-vowel.
  ///
  /// Is equivalent to [r1?.r1].
  ///
  /// See note on R1 and R2  http://snowball.tartarus.org/texts/r1r2.html.
  String? get r2 => r1?.r1;

  /// Set initial y, or y after a vowel, to Y.
  ///
  /// See note on vowel marking at
  /// http://snowball.tartarus.org/texts/vowelmarking.html
  String replaceYs() {
    return replaceFirst(RegExp(r'^y'), 'Y')
        .replaceAll(RegExp('(?<=$rVowels)(y)'), 'Y');
  }

  /// Set initial y, or y after a vowel, to Y.
  ///
  /// See note on vowel marking at
  /// http://snowball.tartarus.org/texts/vowelmarking.html
  String normalizeYs() => replaceAll('Y', 'y');

  /// Selector for all single or double quotation marks and apostrophes.
  static const rQuotes = '[\'"“”„‟’‘‛]';

  /// Trims all quotation marks from start and end of String.
  String removeEnclosingQuotes() => replaceAll(RegExp(r"(^'+)|('+(?=$))"), '');

  /// Replace all forms of apostrophe or quotation mar with U+0027.
  String normalizeQuotesAndApostrophes() => replaceAll(RegExp(rQuotes), "'");

  /// Remove longest of "'", "'s" or "'s'" from end of term.
  ///
  /// The string instance must be in lower case.
  ///
  /// An apostrophe (') may be regarded as a letter. See note on apostrophes
  /// in English (http://snowball.tartarus.org/texts/apostrophe.html).
  String stepZero() => replaceAll(RegExp(r"(('s')|'|('s))(?=$)"), '');

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
  /// - ['inning', 'outing', 'canning', 'herring', 'earring', 'proceed',
  ///   'exceed', 'succeed'].
  String step1A() {
    if (endsWith('sses')) {
      return replaceSuffix('sses', 'ss');
    }
    if (endsWith('ied') || endsWith('ies')) {
      final stub = substring(0, length - 3);
      return stub.length > 1 ? '${stub}i' : '${stub}ie';
    }
    if (endsWith('us') || endsWith('ss')) {
      return this;
    }
    if (endsWith('s')) {
      final stub = substring(0, length - 1);
      final vowelcount = RegExp(rVowels).allMatches(stub).length;
      // If last letter of stub is vowel return unchanged
      if (RegExp(rVowels + r'(?=$)').allMatches(stub).isNotEmpty &&
          vowelcount == 1) {
        return this;
      }
      return RegExp(rVowels).allMatches(stub).isEmpty
          ? this
          : substring(0, length - 1);
    }
    return this;
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
  String step1B() {
    final region1 = r1;
    if (region1 != null &&
        (region1.endsWith('eed') || region1.endsWith('eedly'))) {
      return replaceAll(RegExp(r'(?<=[a-z])(eed|eedly)(?=$)'), 'ee');
    }
    if (endsWith('ed') ||
        endsWith('ing') ||
        endsWith('edly') ||
        endsWith('ingly')) {
      final stub =
          replaceAll(RegExp(r'(?<=[a-z])(ed|edly|ing|ingly)(?=$)'), '');
      if (RegExp('$rVowels+').allMatches(stub).isNotEmpty) {
        if (stub.endsWith('at') || stub.endsWith('bl') || stub.endsWith('iz')) {
          return '${stub}e';
        }
        if (stub.endsWithDouble) {
          return stub.substring(0, stub.length - 1);
        }
        if (stub.endsWithShortSyllable) {
          return '${stub}e';
        }
        return stub;
      }
    }
    return this;
  }

  /// Replace suffix y or Y by i if preceded by a non-vowel which is not the
  /// first letter of the word (so cry -> cri, by -> by, say -> say
  String step1C() =>
      RegExp(r'(?<=\w)' + rNotVowels + r'(?=[yY]$)').allMatches(this).isNotEmpty
          ? replaceAll(RegExp(r'(y|Y)(?=$)'), 'i')
          : this;

  /// Search for the longest among [kStep2Suffixes.keys], and, if found
  /// and in [r1], replace with the corresponding value from [kStep2Suffixes].
  String step2() => r1 != null ? replaceSuffixes(kStep2Suffixes, r1) : this;

  /// Search for the longest among [kStep3Suffixes.keys], and, if found
  /// and in [r1], replace with the corresponding value from [kStep3Suffixes].
  ///
  /// If the String ends with 'ative', delete the suffix if [r2] is not null.
  String step3() => (r2 ?? '').endsWith('ative')
      ? replaceSuffix('ative', '')
      : r1 != null
          ? replaceSuffixes(kStep3Suffixes, r1)
          : this;

  /// Search for the longest among [kStep4Suffixes.keys], and, if found
  /// and in [r1], replace with the corresponding value from [kStep4Suffixes].
  ///
  /// If [r2] ends with 'ion', delete the suffix if preceded by 's' or 't'.
  String step4() {
    final region2 = r2;
    if (region2 != null) {
      if (region2.endsWith('ion') && (endsWith('sion') || endsWith('tion'))) {
        return replaceSuffix('ion', '');
      }
      return replaceSuffixes(kStep4Suffixes, region2);
    }

    return this;
  }

  /// Search for the the following suffixes, and, if found:
  /// - "e": delete if in [r2], or in [r1] and not preceded by a short
  ///   syllable; or
  /// - "l": delete if in [r2] and preceded by an "l".
  String step5() {
    if (r1 != null && (endsWith('e') || endsWith('l'))) {
      final stub = substring(0, length - 1);
      if (endsWith('e')) {
        return (r2 != null || !stub.endsWithShortSyllable) ? stub : this;
      }
      return ((r2 ?? '').endsWith('l') && stub.endsWith('l')) ? stub : this;
    }
    return this;
  }

  /// If the String ends with any of [suffixes.keys], replace the ending with
  /// [suffixes.values] by calling [replaceSuffix].
  String replaceSuffixes(Map<String, String> suffixes, [String? region]) {
    for (final entry in suffixes.entries) {
      final suffix = entry.key;
      if ((region ?? this).endsWith(suffix)) {
        final replacement = entry.value;
        final regex = RegExp('$suffix\$');
        return replaceAll(regex, replacement);
      }
    }
    return this;
  }

  /// If the String ends with any of [suffix], replace the ending with
  /// [replacement].
  String replaceSuffix(String suffix, String replacement) =>
      replaceAll(RegExp('$suffix\$'), replacement);

  /// Returns true if the String's last syllable:
  /// - is a vowel followed by a non-vowel other than w, x or Y and preceded
  ///   by a non-vowel, or
  /// - is a vowel at the beginning of the word followed by a non-vowel.
  bool get endsWithShortSyllable => RegExp('(?<=$rNotVowels)' +
          rVowels +
          r'(?=[^aeiouywxY]$|$)|^' +
          rVowels +
          r'(?=' +
          rNotVowels +
          r'$)')
      .allMatches(this)
      .isNotEmpty;

  /// Returns true if the String ends with any of [rDoubles].
  bool get endsWithDouble => RegExp(rDoubleEnd).allMatches(this).isNotEmpty;

  /// Regular expression selector for characters that are vowels.
  static const rVowels = '[aeiouy]';

  /// Regular expression selector for charactyers that are NOT vowels.
  ///
  /// As the term is in lowercase, this also selects all uppercase letters and,
  /// for that matter, any character not in ['a', 'e', 'i', 'o', 'u', 'y'].
  static const rNotVowels = '[^aeiouy]';

  /// Regular expression selector for double consonants.
  static const rDoubles = 'bb|dd|ff|gg|mm|nn|pp|rr|tt';

  /// Regex string to match String that ends with [rDoubles].
  static const rDoubleEnd = r'(' + rDoubles + r')(?=$)';

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
    'cli': 'c',
    'dli': 'd',
    'eli': 'e',
    'gli': 'g',
    'hli': 'h',
    'kli': 'k',
    'mli': 'm',
    'nli': 'n',
    'rli': 'r',
    'tli': 't',
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
    'al': '',
    'ance': '',
    'ence': '',
    'er': '',
    'ic': '',
    'able': '',
    'ible': '',
    'ant': '',
    'ement': '',
    'ment': '',
    'ent': '',
    'ism': '',
    'ate': '',
    'iti': '',
    'ous': '',
    'ive': '',
    'ize': '',
    'sion': '',
    'tion': '',
  };

  /// Collection of terms that have no stem but do not fit the algorithm.
  static const kStep1AExceptions = {
    'inning': 'inning',
    'proceed': 'proceed',
    'herring': 'herring',
    'earring': 'earring',
    'outing': 'outing',
    'exceed': 'exceed',
    'canning': 'canning',
    'succeed': 'succeed',
  };

  /// Collection of terms that have no stem but do not fit the algorithm.
  static const kInvariantExceptions = {
    'sky': 'sky',
    'news': 'news',
    'howe': 'howe',
    'atlas': 'atlas',
    'cosmos': 'cosmos',
    'bias': 'bias',
    'andes': 'andes',
  };
}
