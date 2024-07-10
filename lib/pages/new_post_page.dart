import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../models/gemini_response.dart';

class NewPostPage extends StatelessWidget {
  late final GeminiResponse? question;

  NewPostPage({this.question = null, super.key});
  final communityUrl = '${dotenv.env['baseUrl']}community/post/';
  late final _titleController;
  late final _contextController;

  void _cancelPost(BuildContext context) {
    Navigator.of(context).pop(null);
  }

  void _sendPostRequest(BuildContext context) async {
    if (_titleController.text.isEmpty || _contextController.text.isEmpty) {
      Fluttertoast.showToast(msg: '글 제목과 내용을 입력해주세요');
      return;
    }
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
      Navigator.of(context).pop(null);
    } else {
      Fluttertoast.showToast(msg: '오류가 발생했습니다');
    }
  }

  void _init() {
    _titleController = TextEditingController();
    if (question == null) {
      _contextController = TextEditingController();
    } else {
      _contextController = TextEditingController(text: '${question!.content}\n${question!.answer}${question!.solution}');
    }
  }

  @override
  Widget build(BuildContext context) {
    _init();
    return Scaffold(
      appBar: AppBar(
        title: const Text('글 쓰기'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contextController,
                textAlignVertical: TextAlignVertical.top,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: '내용을 입력하세요.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _cancelPost(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _sendPostRequest(context),
                  child: const Text('등록'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
