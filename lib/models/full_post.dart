import 'comment.dart';

class FullPost {
  final int postId;
  final String title;
  final String content;
  final List<Comment> comments;

  FullPost({
    required this.postId,
    required this.title,
    required this.content,
    required this.comments,
  });
}