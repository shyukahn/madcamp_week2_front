import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:serverapp/widgets/post_list_view.dart';
import 'package:http/http.dart' as http;

import '../models/simple_post.dart';

class MyScrapPage extends StatefulWidget {
  const MyScrapPage({super.key});

  @override
  State createState() => _MyScrapPageState();
}

class _MyScrapPageState extends State<MyScrapPage> {
  final _userAsync = UserApi.instance.me();
  final _scrapUrl = '${dotenv.env['baseUrl']}community/my_page/scrab_post/';
  final List<SimplePost> _simplePosts = [];
  bool _isLoading = true;

  void refreshPage() {
    setState(() {
      _isLoading = true;
    });
    _getPostsResponse();
  }

  void _getPostsResponse() async {
    final user = await _userAsync;
    final simplePostsResponse = await http.get(
        Uri.parse('$_scrapUrl?kakao_id=${user.id}'),
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
                  comments: jsonMap['comments_count'] as int,
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
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text('스크랩'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          )
      );
    } else if (_simplePosts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('스크랩'),
        ),
        body: const Center(
          child: Text('게시물이 없습니다'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('스크랩'),
        ),
        body: PostListView(simplePosts: _simplePosts, refreshCallback: refreshPage),
      );
    }
  }
}