import 'package:hive/hive.dart';
import 'package:gwa_app/models/library_gwa_submission.dart';

class HiveBoxes {
  static List<String> listTags = ['Favorites', 'Planned'];

  static Box<LibraryGwaSubmission> getLibraryBox() =>
      Hive.box<LibraryGwaSubmission>('library');

  static Future<Box<LibraryGwaSubmission>> openLibraryBox() async {
    return Hive.openBox<LibraryGwaSubmission>('library');
  }

  static LibraryGwaSubmission addLibrarySubmission(
      String title, String fullname, String thumbnailUrl, List<String> lists) {
    final LibraryGwaSubmission libraryGwaSubmission = LibraryGwaSubmission()
      ..title = title
      ..fullname = fullname
      ..thumbnailUrl = thumbnailUrl
      ..lists = lists;
    final box = getLibraryBox();
    box.add(libraryGwaSubmission);
    return libraryGwaSubmission;
  }

  static editLibrarySubmission(LibraryGwaSubmission submission,
      [String title,
      String fullname,
      String thumbnailUrl,
      List<String> lists]) {
    if (title != null && title.isNotEmpty) submission.title = title;
    if (fullname != null && fullname.isNotEmpty) submission.fullname = fullname;
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
      submission.thumbnailUrl = thumbnailUrl;
    if (lists != null) submission.lists = lists;

    submission.save();
  }
}
