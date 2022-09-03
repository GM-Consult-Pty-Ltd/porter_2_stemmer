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
        final retVal = replaceFirst(x, '');
        return retVal.isEmpty ? null : retVal;
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
  String? get r2 {
    final region1 = r1;
    final region2 = region1?.r1;
    return region2;
  }

  /// Selector for all single or double quotation marks and apostrophes.
  static const rQuotes = '[\'"“”„‟’‘‛]';

  bool get isShortWord => r1 == null && endsWithShortSyllable;

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

  /// Returns true if the String's last syllable:
  /// - is a vowel followed by a non-vowel other than w, x or Y and preceded
  ///   by a non-vowel, or
  /// - is a vowel at the beginning of the word followed by a non-vowel.
  bool get endsWithShortSyllable =>
      RegExp('(?<=$rNotVowels)$rVowels(?=[^aeiouywxY]\$)')
          .allMatches(this)
          .isNotEmpty ||
      RegExp('^$rVowels(?=[^aeiouy]\$)').allMatches(this).isNotEmpty;
// '^' + rVowels + r'(?=' + rNotVowels + r'$)'
  /// Returns true if the String ends with any of [rDoubles].
  bool get endsWithDouble => RegExp(rDoubleEnd).allMatches(this).isNotEmpty;

  /// Regular expression selector for characters that are vowels.
  static const rVowels = '[aeiouy]';

  /// Regular expression selector for characters that are NOT vowels.
  ///
  /// As the term is in lowercase, this also selects all uppercase letters and,
  /// for that matter, any character not in ['a', 'e', 'i', 'o', 'u', 'y'].
  static const rNotVowels = '[^aeiouy]';

  /// Regular expression selector for double consonants.
  static const rDoubles = 'bb|dd|ff|gg|mm|nn|pp|rr|tt';

  /// Regex string to match String that ends with [rDoubles].
  static const rDoubleEnd = r'(' + rDoubles + r')(?=$)';

  // /// Collection of terms that have no stem but do not fit the algorithm.
  // static const kInvariantExceptions = {
  //   'sky': 'sky',
  //   'skye': 'skye',
  //   'news': 'news',
  //   'howe': 'howe',
  //   'atlas': 'atlas',
  //   'cosmos': 'cosmos',
  //   'bias': 'bias',
  //   'andes': 'andes',
  // };
}
