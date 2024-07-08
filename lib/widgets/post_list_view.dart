import 'package:flutter/material.dart';

import '../models/simple_post.dart';

class PostListView extends ListView {
  final List<SimplePost> simplePosts;
  PostListView({super.key, required this.simplePosts});

  void _showSelectedPost() {

  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: simplePosts.length,
        itemBuilder: (BuildContext context, int index) {
          final post = simplePosts[index];
          return TextButton(
              onPressed: _showSelectedPost,
              style: TextButton.styleFrom(
                  shape: const ContinuousRectangleBorder()
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    post.summary,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.comment_rounded,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.comments.toString(),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor
                        ),
                      ),
                    ],
                  )
                ],
              )
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
        const Divider(
          height: 0,
          indent: 8.0,
          endIndent: 8.0,
        )
    );
  }
}