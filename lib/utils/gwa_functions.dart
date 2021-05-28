//TODO: Make this work better as well as more efficient.
/// Returns a string of the name of the submission.
String findSubmissionTitle(String fullTitle) {
  if (fullTitle.startsWith(RegExp('[a-z]', caseSensitive: false)) && fullTitle.contains('['))
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