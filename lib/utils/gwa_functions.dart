import 'package:eavesdrop/models/placeholders_options.dart';

class GwaFunctions {
//TODO: Make this work better as well as more efficient.
  /// Returns a string of the name of the submission.
  static String findSubmissionTitle(String fullTitle) {
    if (fullTitle.startsWith(RegExp('[a-z]', caseSensitive: false)) &&
        fullTitle.contains('['))
      return fullTitle.substring(0, fullTitle.indexOf('['));
    var exp = RegExp(r'(?<=\])(.*?)(?=\[)');
    var matches = exp.allMatches(fullTitle);
    var results = List<String>.generate(
        matches.length, (int index) => matches.elementAt(index).group(0));
    for (var title in results) {
      if (RegExp(r'[a-zA-Z]').hasMatch(title)) {
        if (title.contains('&amp;')) {
          return title.substring(0, title.indexOf('&amp;')) +
              '&' +
              title.substring(title.indexOf('&amp;') + 5);
        }
        return title.trim();
      }
    }
/*Check if it starts with a tag and has only 1 tag (for instance
    '[META] hello' or 'Nice to meet you [verification]'). */
    if (fullTitle.contains('[')) {
      var title = fullTitle.substring(0, fullTitle.indexOf('['));
      if (title.isNotEmpty &&
          title.contains(RegExp('[a-z]', caseSensitive: false)))
        return title.trim();
    }
    if (fullTitle.contains(']')) {
      var title =
          fullTitle.substring(fullTitle.lastIndexOf(']') + 1, fullTitle.length);
      if (title.isNotEmpty &&
          title.contains(RegExp('[a-z]', caseSensitive: false)))
        return title.trim();
    }
    return fullTitle;
  }

  static setPlaceholders(PlaceholdersOptions placeholdersOptions) {
    final abstractPlaceholders = [
      'https://images.unsplash.com/photo-1566410812682-b57730be65ff?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80',
      'https://images.unsplash.com/photo-1566410824233-a8011929225c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80',
      'https://images.unsplash.com/photo-1567095716798-1d95d8f4c479?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1050&q=80',
      'https://images.unsplash.com/photo-1602979082099-7971376fce79?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80',
      'https://images.unsplash.com/photo-1607499457689-3fd1ac3ffcdd?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80',
      'https://images.unsplash.com/photo-1508898578281-774ac4893c0c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80',
      'https://images.unsplash.com/photo-1567400358510-f027b3196d5b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1050&q=80',
      'https://images.unsplash.com/photo-1618423771880-2bcfa6b67c89?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80',
      'https://images.unsplash.com/photo-1596027473180-a9cd09320f80?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=333&q=80',
    ];
    final gradientPlaceholders = [
      'https://images.unsplash.com/photo-1618367588421-400296bac364?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=967&q=80',
      'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80',
      'https://images.unsplash.com/photo-1579546929662-711aa81148cf?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80',
      'https://images.unsplash.com/photo-1579547621706-1a9c79d5c9f1?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80',
      'https://images.unsplash.com/photo-1557682224-5b8590cd9ec5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1015&q=80',
      'https://images.unsplash.com/photo-1508614999368-9260051292e5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=750&q=80',
      'https://images.unsplash.com/photo-1557682250-33bd709cbe85?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1015&q=80',
    ];
    switch (placeholdersOptions) {
      case PlaceholdersOptions.Abstract:
        placeholders = abstractPlaceholders;
        break;
      case PlaceholdersOptions.Gradients:
        placeholders = gradientPlaceholders;
        break;
      case PlaceholdersOptions.GoneWildAudioLogo:
        placeholders = ['https://styles.redditmedia.com/t5_2u463/styles/communityIcon_1lj5xecdisi31.png?width=256&s=98e8187f0403751b02c03e7ffb9f059ce0ce18d9'];
        break;
    }
  }

  static List<String> placeholders = [];

  static String getPlaceholderImageUrl(String fullname) {
    var sum = 0;
    fullname.codeUnits.forEach((element) {
      sum += element;
    });
    final int index = sum % placeholders.length;
    return placeholders[index];
  }
}
