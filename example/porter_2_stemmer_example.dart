import 'package:porter_2_stemmer/porter_2_stemmer.dart';

/// Eaxmple usage of [Porter2Stemmer.stem]
void main() {
  //

  /// Collection of terms/words for which stems are printed.
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

  /// Iterate through the [terms] and print the stem for each term.
  for (final term in terms) {
    // Get the stem for the [term].
    final stem = term.stemPorter2();
    // Print the [stem].
    print('$term => $stem');
  }
}
