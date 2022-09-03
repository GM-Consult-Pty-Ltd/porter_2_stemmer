import 'package:porter_2_stemmer/porter_2_stemmer.dart';
import 'data/vocabulary.dart';
import 'package:test/test.dart';

void main() {
  //

  group('Porter English Stemmer', () {
    //
    /// Nothing to do here.
    setUp(() {});

    test('Porter2Stemmer: single', () {
      final term = 'element ';
      final expected = 'element ';
      final stem = term.stemPorter2();
      final failed = stem != expected;
      // expect(failed.isEmpty, true);
      print('${failed ? 'FAIL' : 'PASS'}: $term => $stem (expected '
          '"$expected")');
    });

    test('Porter2Stemmer: extension', () {
      final terms = Map<String, String>.from(vocabulary);
      final failed = _stem(terms);
      // expect(failed.isEmpty, true);
      if (failed.isNotEmpty) {
        for (final fail in failed.entries) {
          print('FAILED: ${fail.key} => ${fail.value} (expected '
              '"${vocabulary[fail.key]}")');
        }
        terms.removeWhere((key, value) => !failed.keys.contains(key));
        _stem(terms);
      } else {
        print('SUCCESS! All tests passed.');
      }
    });
  });

  test('Porter2Stemmer: instance with custom exceptions', () {
    //

    // Preserve the default exceptions.
    final exceptions = Map<String, String>.from(Porter2Stemmer.kExceptions);

    // Add a custom exception for "TSLA".
    exceptions['TSLA'] = 'tesla';

    // Instantiate the [Porter2Stemmer] instance using the custom [exceptions]
    final stemmer = Porter2Stemmer(exceptions: exceptions);

    /// Iterate through the [terms] and print the stem for each term.
    for (final entry in terms.entries) {
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

      // prints "generically => generic"
      // expect(stem, entry.value);
    }
  });
}

/// Global function that returns the failed stems
Map<String, String> _stem(Map<String, String> terms) {
  int failed = 0;
  int passed = 0;
  final failedStems = <String, String>{};
  for (final entry in terms.entries) {
    final stem = entry.key.stemPorter2();
    final result = stem == entry.value ? 'pass' : 'fail';
    // print('${entry.key} => $stem ($result)');
    failed += stem == entry.value ? 0 : 1;
    passed += stem == entry.value ? 1 : 0;
    if (result == 'fail') {
      failedStems[entry.key] = stem;
    }
  }
  print('FAILED: $failed ');
  for (final s in failedStems.entries) {
    print("'${s.key}': '${s.value}',");
  }
  return failedStems;
}

/// Collection of terms/words for which stems are printed.
const terms = {
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

const _vocabulary = {
  'sky’s': 'sky',
  '"news"': 'news',
  "'howe'": 'howe',
  '""atlas""': 'atlas',
  "''cosmos''": 'cosmos',
  'bias': 'bias',
  'andes': 'andes',
  'skis': 'ski',
  'skies': 'sky',
  'dying': 'die',
  'lying': 'lie',
  'tying': 'tie',
  'idly': 'idl',
  'gently': 'gentl',
  'ugly': 'ugli',
  'early': 'earli',
  'only': 'onli',
  'singly': 'singl',
  'consign': 'consign',
  'consigned': 'consign',
  'consigning': 'consign',
  'consignment': 'consign',
  'consist': 'consist',
  'consisted': 'consist',
  'consistency': 'consist',
  'consistent': 'consist',
  'consistently': 'consist',
  'consisting': 'consist',
  'consists': 'consist',
  'consolation': 'consol',
  'consolations': 'consol',
  'consolatory': 'consolatori',
  'console': 'consol',
  'consoled': 'consol',
  'consoles': 'consol',
  'consolidate': 'consolid',
  'consolidated': 'consolid',
  'consolidating': 'consolid',
  'consoling': 'consol',
  'consolingly': 'consol',
  'consols': 'consol',
  'consonant': 'conson',
  'consort': 'consort',
  'consorted': 'consort',
  'consorting': 'consort',
  'conspicuous': 'conspicu',
  'conspicuously': 'conspicu',
  'conspiracy': 'conspiraci',
  'conspirator': 'conspir',
  'conspirators': 'conspir',
  'conspire': 'conspir',
  'conspired': 'conspir',
  'conspiring': 'conspir',
  'constable': 'constabl',
  'constables': 'constabl',
  'constance': 'constanc',
  'constancy': 'constanc',
  'constant': 'constant',
  'knack': 'knack',
  'knackeries': 'knackeri',
  'knacks': 'knack',
  'knag': 'knag',
  'knave': 'knave',
  'knaves': 'knave',
  'knavish': 'knavish',
  'kneaded': 'knead',
  'kneading': 'knead',
  'monday': 'monday',
  'knee': 'knee',
  'kneel': 'kneel',
  'kneeled': 'kneel',
  'kneeling': 'kneel',
  'kneels': 'kneel',
  'knees': 'knee',
  'knell': 'knell',
  'knelt': 'knelt',
  'knew': 'knew',
  'knick': 'knick',
  'knif': 'knif',
  'knife': 'knife',
  'knight': 'knight',
  'knightly': 'knight',
  'knights': 'knight',
  'knit': 'knit',
  'knits': 'knit',
  'knitted': 'knit',
  'knitting': 'knit',
  'knives': 'knive',
  'knob\'s': 'knob',
  '\'knobs': 'knob',
  'knock': 'knock',
  "'knocked'": 'knock',
  'knocker': 'knocker',
  'knockers': 'knocker',
  'knocking': 'knock',
  'knocks': 'knock',
  'knopp': 'knopp',
  'knot': 'knot',
  'knots': 'knot',
  'generate': 'generat',
  'generates': 'generat',
  'generated': 'generat',
  'generating': 'generat',
  'general': 'general',
  'generally': 'general',
  'generic': 'generic',
  'generically': 'generic',
  'generous': 'generous',
  'generously': 'generous',
};
