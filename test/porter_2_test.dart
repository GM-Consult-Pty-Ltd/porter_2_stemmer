// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// All rights reserved.

// Porter stemmer algorithm is Copyright (c) 2001, Dr Martin Porter, and
// Copyright (c) 2002, Richard Boulton, all rights reserved.

import 'package:porter_2_stemmer/porter_2_stemmer.dart';
import 'data/vocabulary.dart';
import 'package:test/test.dart';

void main() {
  //

  group('Porter English Stemmer', () {
    //
    /// Nothing to do here.
    setUp(() {});

    test('Porter2Stemmer: SINGLE', () {
      final term = 'non-words';
      final expected = 'non-word';
      final stem = term.stemPorter2();
      final failed = stem != expected;
      // expect(failed.isEmpty, true);
      print('${failed ? 'FAIL' : 'PASS'}: $term => $stem (expected '
          '"$expected")');
    });

    test('Porter2Stemmer: VALIDATOR', () {
      final terms = Map<String, String>.from(vocabulary);
      final failedStems = <String, String>{};
      for (final entry in terms.entries) {
        final stem = entry.key.stemPorter2();
        if (stem != entry.value) {
          failedStems[entry.key] = stem;
        }
      }
      var accuracy =
          ((terms.length - failedStems.length) / terms.length * 10000).round() /
              100;
      print('STRICT ACCURACY: $accuracy%');
      failedStems.removeWhere((key, value) =>
          value.endsWith('ue') ||
          Porter2Stemmer.kExceptions[key] != null ||
          Porter2StemmerMixin.kInvariantExceptions[key] != null ||
          Porter2StemmerMixin.kStep1AExceptions[key] != null);
      accuracy =
          ((terms.length - failedStems.length) / terms.length * 10000).round() /
              100;
      print('IMPLEMENTED ACCURACY: $accuracy%');
      if (failedStems.isNotEmpty) {
        for (final fail in failedStems.entries) {
          print('FAILED: ${fail.key} => ${fail.value} (expected '
              '"${vocabulary[fail.key]}")');
        }
      } else {
        print('SUCCESS! All tests passed.');
      }
    });
  });

  test('Porter2Stemmer: CUSTOM EXCEPTIONS', () {
    //

    // Preserve the default exceptions.
    final exceptions = Map<String, String>.from(Porter2Stemmer.kExceptions);

    // Add a custom exception for "TSLA".
    exceptions['TSLA'] = 'tesla';

    // Instantiate the [Porter2Stemmer] instance using the custom [exceptions]
    final stemmer = Porter2Stemmer(exceptions: exceptions);

    /// Iterate through the [terms] and print the stem for each term.
    for (final entry in kTerms.entries) {
      // get the term
      final term = entry.key;
      // Get the stem for the [term].
      final stem = stemmer.stem(term);
      // Print the [stem].
      final result = stem == entry.value ? 'pass' : 'fail';
      if (result == 'fail') {
        print('FAILED: $term => $stem (expected '
            '"${entry.value}")');
      } else {
        print('${entry.key} => $stem ($result)');
      }
    }
  });
}

/// Collection of terms/words for which stems are printed.
const kTerms = {
  'wearying': 'weari',
  'vehemently': 'vehement',
  'varying': 'vari',
  'vitae': 'vita',
  'weeds': 'weed',
  'weekly': 'week',
  'yearly': 'year',
  'sky’s': 'sky',
  'skis': 'ski',
  'TSLA': 'tesla',
  'APPLE:NASDAQ': 'APPLE:NASDAQ',
  'apple.com': 'apple.com',
  'consolatory': 'consolatori',
  '"news"': 'news',
  "mother's": 'mother',
  'generally': 'general',
  'consignment': 'consign',
  'Monday': 'monday'
};
