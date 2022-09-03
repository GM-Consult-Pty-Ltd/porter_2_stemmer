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
      final term = 'nearly';
      final expected = 'near';
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
          Porter2Stemmer.kInvariantExceptions[key] != null ||
          Porter2Stemmer.kStep1AExceptions[key] != null);
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

/// A hashmap of {expected:actual} stem values returned by the [Porter2Stemmer]
/// (version 0.0.7).
const failedStems = {
  'accru': 'accrue',
  'afriqu': 'afrique',
  'agu': 'ague',
  'ameriqu': 'amerique',
  'analogu': 'analogue',
  'antiqu': 'antique',
  'argu': 'argue',
  'asiatiqu': 'asiatique',
  'avenu': 'avenue',
  'basqu': 'basque',
  'brusqu': 'brusque',
  'burlesqu': 'burlesque',
  'caciqu': 'cacique',
  'catalogu': 'catalogue',
  'caucahu': 'caucahue',
  'chequ': 'cheque',
  'cimabu': 'cimabue',
  'colleagu': 'colleague',
  'congen': 'congener',
  'constru': 'construe',
  'continu': 'continue',
  'critiqu': 'critique',
  'demagogu': 'demagogue',
  'dialogu': 'dialogue',
  'discontinu': 'discontinue',
  'earli': 'early',
  'ensu': 'ensue',
  'epilogu': 'epilogue',
  'fatigu': 'fatigue',
  'fluentli': 'fluent',
  'fouqu': 'fouque',
  'goodby': 'goodbye',
  'grotesqu': 'grotesque',
  'harangu': 'harangue',
  'harky': 'harki',
  'imbu': 'imbue',
  'intrigu': 'intrigue',
  'iquiqu': 'iquique',
  'issu': 'issue',
  'jacuitqu': 'jacuitque',
  'kotzebu': 'kotzebue',
  'leagu': 'league',
  'looky': 'looki',
  'monologu': 'monologue',
  'obliqu': 'oblique',
  'onli': 'only',
  'opaqu': 'opaque',
  'overdu': 'overdue',
  'pedagogu': 'pedagogue',
  'physiqu': 'physique',
  'picturesqu': 'picturesque',
  'piqu': 'pique',
  'plagu': 'plague',
  'pursu': 'pursue',
  'reliqu': 'relique',
  'rescu': 'rescue',
  'residu': 'residue',
  'retinu': 'retinue',
  'revenu': 'revenue',
  'rogu': 'rogue',
  'schilleresqu': 'schilleresque',
  'statu': 'statue',
  'subaqu': 'subaque',
  'subdu': 'subdue',
  'tissu': 'tissue',
  'tongu': 'tongue',
  'ugli': 'ug',
  'unanu': 'unanue',
  'undervalu': 'undervalue',
  'undu': 'undue',
  'uniqu': 'unique',
  'unpicturesqu': 'unpicturesque',
  'untru': 'untrue',
  'vagu': 'vague',
  'valu': 'value',
  'vinoqu': 'vinoque',
  'virtu': 'virtue',
  'vogu': 'vogue',
};

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

/// Sample vocabulary from
const kVocabulary = {
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
