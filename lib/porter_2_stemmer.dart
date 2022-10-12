// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// All rights reserved.
// Porter stemmer algorithm is Copyright (c) 2001, Dr Martin Porter, and
// Copyright (c) 2002, Richard Boulton, all rights reserved.

/// Reduce a word to its root form using the Porter English stemming algorithm.
library porter_2_stemmer;

export 'src/porter_2_stemmer_extension.dart' show Porter2StemmerExtensions;
export 'src/porter_2_stemmer.dart'
    show
        Porter2Stemmer,
        Porter2StemmerBase,
        Porter2StemmerMixin,
        Porter2StemmerExtension;
