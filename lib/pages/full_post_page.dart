import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/comment.dart';
import '../models/full_post.dart';

class FullPostPage extends StatefulWidget {
  final int postId;
  final communityUrl = '${dotenv.env['baseUrl']}community/post/';

  FullPostPage(this.postId, {super.key});

  @override
  State createState() => _FullPostPageState();
}

class _FullPostPageState extends State<FullPostPage> {
  bool _isLoading = true;
  FullPost? fullPost;

  void _getPostResponse() async {
    final postResponse = await http.get(Uri.parse(widget.communityUrl + widget.postId.toString()));
    if (postResponse.statusCode == 200) {
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(jsonDecode(postResponse.body));
      final List<Map<String, dynamic>> commentObjects = List<Map<String, dynamic>>.from(jsonMap['comments']);
      fullPost = FullPost(
        postId: jsonMap['post_id'] as int,
        title: jsonMap['title'] as String,
        content: jsonMap['content'] as String,
        comments: [
          for (var comment in commentObjects)
            Comment(content: comment['content'] as String)
        ],
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _getPostResponse();
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
    } else if (fullPost == null) {
      return const Scaffold(
        body: Center(
          child: Text('게시물을 불러오는데 실패했습니다'),
        )
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('게시물 보기'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _postBody(),
                _postComments(),
              ],
            ),
          )
        )
      );
    }
  }

  Widget _postBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullPost!.title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          fullPost!.content,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _fromComment(Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(comment.content)
      ],
    );
  }

  Widget _postComments() {
    return Column(
      children: fullPost!.comments.map(_fromComment).toList(),
    );
  }
}