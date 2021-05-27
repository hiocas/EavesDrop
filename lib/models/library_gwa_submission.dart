import 'package:hive/hive.dart';

/* For hive, I could save only the fullname of the submission and then populate
them. But I think that adding the rest of the fields for faster load times
would be better. */
part 'library_gwa_submission.g.dart';

@HiveType(typeId: 1)
class LibraryGwaSubmission extends HiveObject{
  @HiveField(0)
  String title;
  @HiveField(1)
  String fullname;
  @HiveField(2)
  String thumbnailUrl;
  @HiveField(3)
  List<String> lists;
}
