import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:serverapp/pages/new_post_page.dart';
import 'package:serverapp/widgets/post_list_view.dart';
import 'package:http/http.dart' as http;

import '../models/simple_post.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final communityUrl = '${dotenv.env['baseUrl']}community/post/';
  final List<SimplePost> _simplePosts = [];
  bool _isLoading = true;

  void _writePost() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NewPostPage())
    );
  }

  void _getPostsResponse() async {
    final simplePostsResponse = await http.get(Uri.parse(communityUrl));
    if (simplePostsResponse.statusCode == 200) {
      final simplePostsString = simplePostsResponse.body;
      final List<Map<String, dynamic>> jsonList = List<Map<String, dynamic>>.from(jsonDecode(simplePostsString));
      for (var jsonMap in jsonList) {
        _simplePosts.add(
          SimplePost(
            postId: jsonMap['post_id'] as int,
            title: jsonMap['title'] as String,
            summary: '${jsonMap['summary'] as String}...',
            comments: jsonMap['comments_count'] as int
          )
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _getPostsResponse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        )
      );
    } else if (_simplePosts.isEmpty) {
      return const Scaffold(
      body: Center(
        child: Text('게시물이 없습니다'),
      )
      );
    } else {
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
}