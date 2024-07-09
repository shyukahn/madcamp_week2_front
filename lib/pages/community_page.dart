import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
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

  void refreshPage() {
    setState(() {
      _isLoading = true;
    });
    _getPostsResponse();
  }

  void _writePost() {
    Navigator.of(context).push(
        PageTransition(
          child: NewPostPage(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: 150),
          reverseDuration: Duration(milliseconds: 150),
          curve: Curves.easeInOutBack,
          inheritTheme: true,
          ctx: context,
        )
    ).then((_) => refreshPage());
  }

  void _getPostsResponse() async {
    final simplePostsResponse = await http.get(
      Uri.parse(communityUrl),
      headers: {
        "Cache-Control" : "no-cache, no-store, must-revalidate"
      }
    );
    if (simplePostsResponse.statusCode == 200) {
      final simplePostsString = simplePostsResponse.bodyBytes;
      final List<Map<String, dynamic>> jsonList = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(simplePostsString)));

      setState(() {
        _simplePosts.clear(); // Clear the list before adding new items
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
        _isLoading = false; // Update loading state
      });
    } else {
      setState(() {
        _isLoading = false; // Update loading state even if the response is not successful
      });
    }
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
      return Scaffold(
        body: const Center(
          child: Text('게시물이 없습니다'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _writePost,
          shape: const CircleBorder(),
          child: const Icon(Icons.create),
        ),
      );
    } else {
      return Scaffold(
        body: PostListView(simplePosts: _simplePosts),
        floatingActionButton: FloatingActionButton(
          onPressed: _writePost,
          shape: const CircleBorder(),
          child: const Icon(Icons.create),
        ),
      );
    }
  }
}