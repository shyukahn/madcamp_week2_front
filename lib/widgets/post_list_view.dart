import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/simple_post.dart';
import '../pages/full_post_page.dart';

class PostListView extends StatelessWidget {
  final List<SimplePost> simplePosts;
  final communityUrl = '${dotenv.env['baseUrl']}community/post/';

  PostListView({super.key, required this.simplePosts});

  void _showSelectedPost(BuildContext context, SimplePost simplePost) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => FullPostPage(simplePost.postId))
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding:EdgeInsets.all(8.0),
        itemCount: simplePosts.length,
        itemBuilder: (BuildContext context, int index) {
          final post = simplePosts[index];
          return GestureDetector(
            onTap: () => _showSelectedPost(context, post),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
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
                  const SizedBox(height: 4.0),
                  Text(
                    post.summary,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(height: 8.0) // add spacing between items
    );
  }
}
