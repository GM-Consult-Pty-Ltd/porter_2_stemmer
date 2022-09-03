import 'package:porter_2_stemmer/porter_2_stemmer.dart';

void main() {
  //

  // the collection of terms/words for which stems are printed.
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

  /// A string extension is provided, and is the simplest way to get stemming
  extensionExample(terms);

  /// To implement custom exceptions to the algorithm, provide the exceptions parameter (a hashmap of String:String) that provides the term (key) and its stem (value).
  ///
  /// The next example instantiates a Porter2Stemmer instance, and passes
  /// in a custom exception for the term "TSLA".
  instanceExample(terms);
}

/// Example usage of [Porter2StemmerExtension.stemPorter2] extension.
///
/// Iterate through a collection of terms/words and print the stem for each
/// term.
void extensionExample(Iterable<String> terms) {
  //

  // print a heading
  print('Example usage of [Porter2StemmerExtension.stemPorter2] extension');

  /// Iterate through the [terms] and print the stem for each term.
  for (final term in terms) {
    // Get the stem for the [term] by calling the stem2Porter() extension
    // method.
    final stem = term.stemPorter2();

    // Print the [term => stem].
    print('$term => $stem');
  }
}

/// Example usage of [Porter2Stemmer.stem] method.
///
/// Instantiates a [Porter2Stemmer] instance using custom a exception for
/// the term "TSLA".
///
/// Prints the terms and their stems.
void instanceExample(Iterable<String> terms) {
  //

  // print a heading
  print('Example usage of [Porter2Stemmer.stem] method');

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
