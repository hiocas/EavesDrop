import 'package:draw/draw.dart';

class SearchFunctions {
  static String sortToString(Sort sort) {
    switch (sort) {
      case Sort.relevance:
        return 'Relevance';
      case Sort.hot:
        return 'Hot';
      case Sort.top:
        return 'Top';
      case Sort.newest:
        return 'Newest';
      case Sort.comments:
        return 'Comments';
      default:
        return '';
    }
  }

  static String timeFilterToString(TimeFilter timeFilter) {
    switch (timeFilter) {
      case TimeFilter.all:
        return 'All';
      case TimeFilter.day:
        return 'Day';
      case TimeFilter.hour:
        return 'Hour';
      case TimeFilter.month:
        return 'Month';
      case TimeFilter.week:
        return 'Week';
      case TimeFilter.year:
        return 'Year';
      default:
        return '';
    }
  }

  static bool timeFilterRelevant(Sort sort) {
    return sort == Sort.top || sort == Sort.relevance || sort == Sort.comments;
  }

  static TimeFilter getSortedTimeFilterValue(int index) {
    switch (index) {
      case 0:
        return TimeFilter.all;
      case 1:
        return TimeFilter.year;
      case 2:
        return TimeFilter.month;
      case 3:
        return TimeFilter.week;
      case 4:
        return TimeFilter.day;
      case 5:
        return TimeFilter.hour;
      default:
        return TimeFilter.values[index];
    }
  }

  static int getSortIndex(Sort sort) {
    for (var i = 0; i < Sort.values.length; i++) {
      if (Sort.values[i] == sort) return i;
    }
    return 0;
  }

  static int getTimeFilterIndex(TimeFilter timeFilter) {
    for (var i = 0; i < TimeFilter.values.length; i++) {
      if (getSortedTimeFilterValue(i) == timeFilter) return i;
    }
    return 0;
  }
}
