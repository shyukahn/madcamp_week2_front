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
  final TextEditingController _commentController = TextEditingController();

  void _getPostResponse() async {
    final postResponse = await http.get(Uri.parse(widget.communityUrl + widget.postId.toString()));
    if (postResponse.statusCode == 200) {
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(jsonDecode(postResponse.body));
      final List<Map<String, dynamic>> commentObjects = List<Map<String, dynamic>>.from(jsonMap['comments']);
      setState(() {
        fullPost = FullPost(
          postId: jsonMap['post_id'] as int,
          title: jsonMap['title'] as String,
          content: jsonMap['content'] as String,
          comments: [
            for (var comment in commentObjects)
              Comment(content: comment['content'] as String)
          ],
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addComment() {
    final String commentText = _commentController.text;
    if (commentText.isNotEmpty) {
      setState(() {
        fullPost?.comments.add(Comment(content: commentText));
        _commentController.clear();
      });
    }
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
        ),
      );
    } else if (fullPost == null) {
      return const Scaffold(
        body: Center(
          child: Text('게시물을 불러오는데 실패했습니다'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('게시물 보기'),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _postBody(),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey, thickness: 1.5),
                      _postComments(),
                      const SizedBox(height: 80), // To avoid the last comment being hidden behind the input field
                    ],
                  ),
                ),
              ),
            ),
            _commentInputField(),
          ],
        ),
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
        const SizedBox(height: 8),
        Text(
          fullPost!.content,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _fromComment(Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          comment.content,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _postComments() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fullPost!.comments.length,
      itemBuilder: (context, index) {
        return _fromComment(fullPost!.comments[index]);
      },
    );
  }

  Widget _commentInputField() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  hintText: '댓글 작성'
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addComment,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
