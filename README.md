# porter_2_stemmer
DART implementation of the Porter Stemming Algorithm, used for reducing a word to its word stem, base or root form.

## What is the Porter Stemming Algorithm?

The Porter stemming algorithm (or 'Porter stemmer') is a process for removing the commoner morphological and inflexional endings from words in English. Its main use is as part of a term normalisation process that is usually done when setting up information retrieval systems.

The English (Porter2) stemming algorithm was developed as part of "Snowball", a small string processing language designed for creating stemming algorithms for use in information retrieval.

The Porter 2 algorithm is Copyright (c) 2001, Dr Martin Porter and Copyright (c) 2002, Richard Boulton and licensed under the BSD 3-Clause License (https://opensource.org/licenses/BSD-3-Clause). 

You can read more about the Porter Stemming Algorithm [[here](https://snowballstem.org/algorithms/)].

## Installation

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  porter_2_stemmer: <latest_version>
```

In your library add the following import:

```dart
import 'package:porter_2_stemmer/porter_2_stemmer.dart';
```
