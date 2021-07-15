class SearchDetails {
  String author = '';
  String includedTags = '';

  SearchDetails(this.author, this.includedTags);

  SearchDetails.fromQuery(String searchQuery) {
    this.author = getAuthor(searchQuery);
    this.includedTags = getIncludedTags(searchQuery);
  }

  formatIncludedTags() {
    String currentIncludedTags = '';
    var exp = RegExp(r'(?<=\")(.*?)(?=\")');
    var matches = exp.allMatches(this.includedTags);
    if (matches.length > 0) {
      for (var i = 0; i < matches.length - 1; i++) {
        if (matches.elementAt(i).group(0).trim().isNotEmpty) {
          currentIncludedTags += '"${matches.elementAt(i).group(0)}" ';
        }
      }
      this.includedTags = currentIncludedTags + '"${matches.last.group(0)}"';
    }
  }

  String toString() {
    return 'author: "${this.author}",\nincluded_tags: ${this.includedTags}.';
  }

  static String toQuery(String searchQuery, SearchDetails newDetails) {
    final SearchDetails currentDetails = SearchDetails.fromQuery(searchQuery);
    if (newDetails.author.isNotEmpty) {
      if (currentDetails.author.isEmpty) {
        searchQuery += 'author:"${newDetails.author}"';
      } else {
        final List<int> range = getAuthorRange(searchQuery);
        searchQuery = searchQuery.substring(0, range[0]) +
            newDetails.author +
            searchQuery.substring(range[1]);
      }
    }
    print('new: ${newDetails.includedTags}');

    if (newDetails.includedTags.isNotEmpty) {
      if (currentDetails.includedTags.isEmpty) {
        if (searchQuery.isNotEmpty) searchQuery += ' ';
        searchQuery += 'title:' + newDetails.includedTags;
      } else {
        final List<int> range = getIncludedTagsRange(searchQuery);
        searchQuery = searchQuery.substring(0, range[0]) +
            newDetails.includedTags +
            searchQuery.substring(range[1]);
      }
    } else {
      if (currentDetails.includedTags.isNotEmpty) {
        print('hey');
        final List<int> range = getIncludedTagsRange(searchQuery);
        range[0] -= 6;
        print(searchQuery.substring(range[0], range[1]));
        searchQuery = searchQuery.replaceRange(range[0], range[1], '');
      }
    }
    return searchQuery;
  }

  static List<int> getAuthorRange(String searchQuery) {
    int authorIndex = searchQuery.indexOf('author:"') + 8;
    if (authorIndex != 7) {
      final String chop = searchQuery.substring(authorIndex);
      final int end = chop.indexOf('"') + authorIndex;
      return [authorIndex, end];
    }
    return [];
  }

  static String getAuthor(String searchQuery) {
    final List<int> range = getAuthorRange(searchQuery);
    if (range.isEmpty) return '';
    return searchQuery.substring(range[0], range[1]);
  }

  static List<int> getIncludedTagsRange(String searchQuery) {
    int titleIndex = searchQuery.indexOf('title:"') + 6;
    if (titleIndex != 5) {
      final String includedTags = searchQuery.substring(titleIndex);
      final int end = includedTags.lastIndexOf('"') + 1 + titleIndex;
      return [titleIndex, end];
    }
    return [];
  }

  static String getIncludedTags(String searchQuery) {
    final List<int> range = getIncludedTagsRange(searchQuery);
    if (range.isNotEmpty) {
      return searchQuery.substring(range[0], range[1]);
    }
    return '';
  }
}
