import 'package:serverapp/models/user.dart';

class Comment {
  final String content;
  final AppUser appUser;

  Comment({required this.content, required this.appUser});
}