// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// All rights reserved.

// Porter stemmer algorithm is Copyright (c) 2001, Dr Martin Porter, and
// Copyright (c) 2002, Richard Boulton, all rights reserved.

import 'porter_2_stemmer.dart';
import 'porter_2_stemmer_constants.dart';

/// Implementation extensions on [String] for [Porter2StemmerMixin].
extension Porter2StemmerExtensions on String {
  //

  /// The region after the first non-vowel following a vowel, or the end of
  /// the word if there is no such non-vowel.
  ///
  /// If the words begins gener, commun or arsen, [r1] is the remainder of the
  /// word after gener, commun or arsen is removed from the beginning.
  ///
  /// See note on R1 and R2  http://snowball.tartarus.org/texts/r1r2.html.
  String? get r1 {
    for (final x in Porter2StemmerConstants.kRegion1Exceptions) {
      if (startsWith(x)) {
        final retVal = replaceFirst(x, '');
        return retVal.isEmpty ? null : retVal;
      }
    }
    return RegExp(r'(?<=(' +
            Porter2StemmerConstants.rVowels +
            Porter2StemmerConstants.rNotVowels +
            r'))\w+(?=$)')
        .firstMatch(this)
        ?.group(0);
  }

  /// The region after the first non-vowel following a vowel in [r1], or the
  /// end of the word if there is no such non-vowel.
  ///
  /// Is equivalent to `r1?.r1`.
  ///
  /// See note on R1 and R2  http://snowball.tartarus.org/texts/r1r2.html.
  String? get r2 {
    final region1 = r1;
    final region2 = region1?.r1;
    return region2;
  }

  /// Returns true if the String's last syllable:
  /// - is a vowel followed by a non-vowel other than w, x or Y and preceded
  ///   by a non-vowel, or
  /// - is a vowel at the beginning of the word followed by a non-vowel.
  bool get endsWithShortSyllable =>
      RegExp('(?<=${Porter2StemmerConstants.rNotVowels})${Porter2StemmerConstants.rVowels}(?=[^aeiouywxY]\$)')
          .allMatches(this)
          .isNotEmpty ||
      RegExp('^${Porter2StemmerConstants.rVowels}(?=[^aeiouy]\$)')
          .allMatches(this)
          .isNotEmpty;

  /// Returns true if the String ends with any of
  /// [Porter2StemmerConstants.rDoubles].
  bool get endsWithDouble =>
      RegExp(Porter2StemmerConstants.rDoubleEnd).allMatches(this).isNotEmpty;

  /// Returns true if:
  /// - the String is all aupper case (e.g. TSLA); or
  /// - the lowercase version of the String contains any [Porter2StemmerConstants.rEnglishNonWordChars].
  bool get isIdentifier =>
      toUpperCase() == this ||
      RegExp(Porter2StemmerConstants.rEnglishNonWordChars)
          .allMatches(this)
          .isNotEmpty;

  /// Returns true if [r1] is null and [endsWithShortSyllable] is true.
  bool get isShortWord => r1 == null && endsWithShortSyllable;

  //
}
