import 'package:flutter/material.dart';
import 'package:serverapp/widgets/post_list_view.dart';

import '../models/simple_post.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<SimplePost> _simplePosts = [];

  void _writePost() {

  }


  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 40; i++) {
      _simplePosts.add(SimplePost(title: 'Title $i', summary: 'Summary $i', comments: i % 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PostListView(simplePosts: _simplePosts)
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _writePost,
        shape: const CircleBorder(),
        child: const Icon(Icons.create),
      ),
    );
  }
}