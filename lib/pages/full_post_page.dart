import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:serverapp/models/user.dart';

import '../models/comment.dart';
import '../models/full_post.dart';

class FullPostPage extends StatefulWidget {
  final int postId;

  const FullPostPage(this.postId, {super.key});

  @override
  State createState() => _FullPostPageState();
}

class _FullPostPageState extends State<FullPostPage> {
  bool _isLoading = true;
  bool _isCommentAvailable = true;
  bool _isScrapped = false;
  FullPost? fullPost;
  final _userAsync = UserApi.instance.me();
  final _communityUrl = '${dotenv.env['baseUrl']}community/post/';
  final _commentUrl = '${dotenv.env['baseUrl']}community/save_comment/';
  final _scrapUrl = '${dotenv.env['baseUrl']}community/post/scrab/';
  final _deleteScrapUrl = '${dotenv.env['baseUrl']}community/delete_scrab/';
  final _deletePostUrl = '${dotenv.env['baseUrl']}community/post_delete/';
  final TextEditingController _commentController = TextEditingController();

  void _getPostResponse() async {
    final user = await _userAsync;
    final postResponse = await http.get(Uri.parse('$_communityUrl${widget.postId}/?kakao_id=${user.id}'));
    if (postResponse.statusCode == 200) {
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(jsonDecode(utf8.decode(postResponse.bodyBytes)));
      final List<Map<String, dynamic>> commentObjects = List<Map<String, dynamic>>.from(jsonMap['comments']);
      final Map<String, dynamic> userObject = Map<String, dynamic>.from(jsonMap['user']);
      setState(() {
        fullPost = FullPost(
          postId: jsonMap['post_id'] as int,
          title: jsonMap['title'] as String,
          content: jsonMap['content'] as String,
          comments: commentObjects.map(
                  (Map<String, dynamic> commentMap) {
                final commentUser = Map<String, dynamic>.from(commentMap['user']);
                return Comment(
                    content: commentMap['content'] as String,
                    appUser: AppUser(
                      userId: int.parse(commentUser['kakao_id'] as String),
                      nickname: commentUser['nickname'] as String,
                      thumbnailUrl: commentUser['thumbnail_image'] as String,
                    )
                );
              }
          ).toList(),
          appUser: AppUser(
            userId: int.parse(userObject['kakao_id'] as String),
            nickname: userObject['nickname'] as String,
            thumbnailUrl: userObject['thumbnail_image'] as String,
          ),
          isScrapped: jsonMap['boolean_value'] as bool,
        );
        _isLoading = false;
        _isScrapped = fullPost!.isScrapped;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addComment() async {
    final String commentText = _commentController.text;
    if (commentText.isNotEmpty) {
      setState(() {
        _isCommentAvailable = false;
      });
      final user = await _userAsync;
      final now = DateTime.now();
      final commentResponse = await http.post(
          Uri.parse(_commentUrl),
          body: {
            "post" : widget.postId.toString(),
            "created_at" : "${DateFormat('yyyy-MM-dd').format(now)}T${DateFormat('HH:mm:ss').format(now)}Z",
            "kakao_id" : user.id.toString(),
            "content" : commentText,
          }
      );
      if (commentResponse.statusCode == 201) {
        setState(() {
          fullPost?.comments.add(
            Comment(
              content: commentText,
              appUser: AppUser(
                userId: user.id,
                nickname: user.kakaoAccount!.profile!.nickname!,
                thumbnailUrl: user.kakaoAccount!.profile!.thumbnailImageUrl!,
              )
            )
          );
          _commentController.clear();
        });
        Fluttertoast.showToast(msg: '댓글이 등록되었습니다');
      } else {
        Fluttertoast.showToast(msg: '오류가 발생했습니다');
      }
      setState(() {
        _isCommentAvailable = true;
      });
    } else {
      Fluttertoast.showToast(msg: '댓글 내용을 입력해주세요');
    }
  }

  void _toggleScrap() async {
    if (!_isScrapped) {
      // 스크랩 추가
      final user = await _userAsync;
      final scrapResponse = await http.post(
          Uri.parse(_scrapUrl),
          body: {
            "post" : fullPost!.postId.toString(),
            "kakao_id" : user.id.toString(),
          }
      );
      if (scrapResponse.statusCode == 201) {
        setState(() {
          _isScrapped = true;
        });
      } else {
        Fluttertoast.showToast(msg: '오류가 발생했습니다');
      }
    } else {
      // 스크랩 취소
      final user = await _userAsync;
      final scrapResponse = await http.delete(
          Uri.parse('$_deleteScrapUrl?post_id=${fullPost!.postId}&kakao_id=${user.id}')
      );
      if (scrapResponse.statusCode == 204) {
        setState(() {
          _isScrapped = false;
        });
      } else {
        Fluttertoast.showToast(msg: '오류가 발생했습니다');
      }
    }
  }

  void _deleteCurrentPage() async {
    print('_deleteCurrentPage');
    final user = await _userAsync;
    final url = '$_deletePostUrl?kakao_id=${user.id}&post_id=${fullPost!.postId}';
    print(url);
    final deleteResponse = await http.delete(Uri.parse('$_deletePostUrl?kakao_id=${user.id}&post_id=${fullPost!.postId}'));
    if (deleteResponse.statusCode == 204) {
      Fluttertoast.showToast(msg: '게시글이 삭제되었습니다');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(msg: '오류가 발생했습니다');
      Navigator.of(context).pop();
    }
  }
  
  void _showDeleteDialog(String value) async {
    if (value == 'delete') {
      final user = await _userAsync;
      if (user.id != fullPost!.appUser.userId) {
        Fluttertoast.showToast(msg: '내가 쓴 글만 삭제할 수 있습니다');
        Navigator.of(context).pop();
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            content: Text('게시물을 삭제하시겠습니까?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actionsPadding: EdgeInsets.all(8.0),
            actions: [
              TextButton(
                onPressed: () =>
                  Navigator.of(context).pop(),
                child: Text('취소')
              ),
              TextButton(
                onPressed: _deleteCurrentPage,
                child: Text('확인')
              ),
            ],
          );
        }
      );
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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('게시물 보기'),
        ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _postBody(),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey, thickness: 1.5),
                      _postComments(),
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
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                  fullPost!.appUser.thumbnailUrl
              ),
            ),
            SizedBox(width: 8.0,),
            Text(
              fullPost!.appUser.nickname,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: _toggleScrap,
              iconSize: 28.0,
              icon: _isScrapped
                  ? Stack(
                children: [
                  Icon(Icons.star, color: Colors.yellow,),
                  Icon(Icons.star_border, color: Colors.black),
                ],
              )
                  : Icon(Icons.star_border, color: Colors.black,)
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)
              ),
              onSelected: _showDeleteDialog,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    child: Text('삭제'),
                    value: 'delete',
                  )
                ];
              }
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Text(
          fullPost!.title,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          fullPost!.content,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 16,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(
                        comment.appUser.thumbnailUrl
                    ),
                  ),
                  SizedBox(width: 6.0,),
                  Text(
                    comment.appUser.nickname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0,),
              Text(
                comment.content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          )
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
              onPressed: _isCommentAvailable ? _addComment : null,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
