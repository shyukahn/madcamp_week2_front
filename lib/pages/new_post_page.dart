import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class NewPostPage extends StatelessWidget {
  NewPostPage({super.key});
  final communityUrl = '${dotenv.env['baseUrl']}community/post/';
  final _titleController = TextEditingController();
  final _contextController = TextEditingController();

  void _cancelPost(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _sendPostRequest() async {
    final user = await UserApi.instance.me();
    final now = DateTime.now();
    final response = await http.post(Uri.parse(communityUrl),
      body: {
        "kakao_id" : user.id.toString(),
        "title" : _titleController.text,
        "content" : _contextController.text,
        "created_at" : "${DateFormat('yyyy-MM-dd').format(now)}T${DateFormat('HH:mm:ss').format(now)}Z",
        "post_picture" : "",
      }
    );
    if (response.statusCode == 201) {
      Fluttertoast.showToast(msg: '게시물이 등록되었습니다');
    } else {
      Fluttertoast.showToast(msg: '오류가 발생했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글 쓰기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: '제목',
              ),
            ),
            TextField(
              controller: _contextController,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요.',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _cancelPost(context),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    _sendPostRequest();
                    Navigator.of(context).pop();
                  },
                  child: Text('등록'),
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}