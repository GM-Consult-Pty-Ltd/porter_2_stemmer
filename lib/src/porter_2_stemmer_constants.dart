// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// All rights reserved.

/// All the constants used by the Porter2Stemmer implementation classes.
abstract class Porter2StemmerConstants {
  //

  /// Suffix hasmap for Step 1B.
  static const kStep1BSuffixes = {
    'ingly': '',
    'edly': '',
    'ing': '',
    'ed': '',
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

  /// Collection of default exceptions used by [Porter2StemmerMixin].
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

  /// Regular expression selector for characters that are vowels.
  static const rVowels = '[aeiouyà-æè-ðò-öø-ÿ]';

  /// Regular expression selector for characters that are NOT vowels.
  ///
  /// As the term is in lowercase, this also selects all uppercase letters and,
  /// for that matter, any character not in `['a', 'e', 'i', 'o', 'u', 'y']`.
  static const rNotVowels = '[^aeiouyà-æè-ðò-öø-ÿ]';

  /// Selector that matches any character not a letter, a hyphen
  /// or apostrophe.
  static const rEnglishNonWordChars = r"[^a-zA-ZÀ-öø-ÿ'\-]+";

  /// Words starting with any of the following have a different Region 1 to
  /// the algorithm.
  ///
  /// If the words begins with  (gener, commun or arsen), R1 is the remainder
  /// of the word after gener, commun or arsen is removed from the beginning.
  static const kRegion1Exceptions = ['gener', 'commun', 'arsen'];

  /// Regular expression selector for double consonants.
  static const rDoubles = 'bb|dd|ff|gg|mm|nn|pp|rr|tt';

  /// Regex string to match String that ends with [rDoubles].
  static const rDoubleEnd = r'(' + rDoubles + r')(?=$)';

  /// Selector for all single or double quotation marks and apostrophes.
  static const rQuotes = '[\'"“”„‟’‘‛]';

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
}
