import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';

import '../models/simple_post.dart';
import '../pages/full_post_page.dart';

class PostListView extends StatefulWidget {
  final List<SimplePost> simplePosts;
  final void Function() refreshCallback;

  const PostListView({super.key, required this.simplePosts, required this.refreshCallback});

  @override
  State createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  final communityUrl = '${dotenv.env['baseUrl']}community/post/';

  void _showSelectedPost(BuildContext context, SimplePost simplePost) {
    Navigator.of(context).push(
        PageTransition(
          child: FullPostPage(simplePost.postId),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: 120),
          reverseDuration: Duration(milliseconds: 120),
          inheritTheme: true,
          ctx: context,
        )
    ).then((_) => widget.refreshCallback());
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: ListView.separated(
            padding:EdgeInsets.all(12.0),
            itemCount: widget.simplePosts.length,
            itemBuilder: (BuildContext context, int index) {
              final post = widget.simplePosts[index];
              return GestureDetector(
                onTap: () => _showSelectedPost(context, post),
                child: Container(
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
        )
    );
  }
}



