import 'package:porter_2_stemmer/porter_2_stemmer.dart';

/// Example usage of [Porter2StemmerExtension.stemPorter2] extension.
///
/// Iterate through a collection of terms/words and print the stem for each
/// term.
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
    print('$term => $stem'); // prints "generically => generic"
  }
}
