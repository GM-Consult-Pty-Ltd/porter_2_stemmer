import 'package:porter_2_stemmer/porter_2_stemmer.dart';

/// Example usage of [Porter2Stemmer.stem] method.
///
/// Instantiates a [Porter2Stemmer] instance using custom a exception for
/// the term "TSLA".
///
/// Prints the terms and their stems.
void main() {
  //

  // collection of terms/words for which stems are printed.
  final terms = [
    'sky’s',
    'skis',
    'TSLA',
    'APPLE:NASDAQ',
    'apple.com',
    'consolatory',
    '"news"',
    "mother's",
    'generally',
    'consignment'
  ];

  // Preserve the default exceptions.
  final exceptions = Map<String, String>.from(Porter2Stemmer.kExceptions);

  // Add a custom exception for "TSLA".
  exceptions['TSLA'] = 'tesla';

  // Instantiate the [Porter2Stemmer] instance using the custom [exceptions]
  final stemmer = Porter2Stemmer(exceptions: exceptions);

  /// Iterate through the [terms] and print the stem for each term.
  for (final term in terms) {
    // Get the stem for the [term].
    final stem = stemmer.stem(term);

    // Print the [term => stem].
    print('$term => $stem');
  }
}
