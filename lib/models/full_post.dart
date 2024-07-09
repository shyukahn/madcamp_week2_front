import 'package:serverapp/models/user.dart';

import 'comment.dart';

class FullPost {
  final int postId;
  final String title;
  final String content;
  final List<Comment> comments;
  final AppUser appUser;
  final bool isScrapped;

  FullPost({
    required this.postId,
    required this.title,
    required this.content,
    required this.comments,
    required this.appUser,
    required this.isScrapped,
  });
}