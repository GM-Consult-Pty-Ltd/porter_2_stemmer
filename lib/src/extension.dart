// BSD 3-Clause License
// Copyright (c) 2022, GM Consult Pty Ltd
// Copyright (c) 2001, Dr Martin Porter,
// Copyright (c) 2002, Richard Boulton.
// All rights reserved.

import 'package:porter_2_stemmer/porter_2_stemmer.dart';

/// Extends [String] to provide the [stemPorter2] method.
extension PorterStemmerExtensionOnString on String {
  //

  /// Reduces the String to its word stem, base or root form.
  /// using the [Porter2Stemmer] English language stemming algorithm.
  ///
  /// This is a shortcut to the static function [Porter2Stemmer.stem].
  String stemPorter2([Map<String, String>? exceptions]) =>
      Porter2Stemmer(exceptions: exceptions).stem(this);

  //
}
